import asyncio
import traceback
from datetime import datetime
from datetime import timedelta

from loguru import logger
from sqlalchemy import func
from sqlalchemy import select

from app import activitypub as ap
from app import httpsig
from app import models
from app.boxes import save_to_inbox
from app.database import AsyncSession
from app.database import async_session
from app.database import now

_MAX_RETRIES = 5


async def new_ap_incoming_activity(
    db_session: AsyncSession,
    httpsig_info: httpsig.HTTPSigInfo,
    raw_object: ap.RawObject,
) -> models.IncomingActivity:
    incoming_activity = models.IncomingActivity(
        sent_by_ap_actor_id=httpsig_info.signed_by_ap_actor_id,
        ap_id=ap.get_id(raw_object),
        ap_object=raw_object,
    )
    db_session.add(incoming_activity)
    await db_session.commit()
    await db_session.refresh(incoming_activity)
    return incoming_activity


def _exp_backoff(tries: int) -> datetime:
    seconds = 2 * (2 ** (tries - 1))
    return now() + timedelta(seconds=seconds)


def _set_next_try(
    outgoing_activity: models.IncomingActivity,
    next_try: datetime | None = None,
) -> None:
    if not outgoing_activity.tries:
        raise ValueError("Should never happen")

    if outgoing_activity.tries == _MAX_RETRIES:
        outgoing_activity.is_errored = True
        outgoing_activity.next_try = None
    else:
        outgoing_activity.next_try = next_try or _exp_backoff(outgoing_activity.tries)


async def process_next_incoming_activity(db_session: AsyncSession) -> bool:
    where = [
        models.IncomingActivity.next_try <= now(),
        models.IncomingActivity.is_errored.is_(False),
        models.IncomingActivity.is_processed.is_(False),
    ]
    q_count = await db_session.scalar(
        select(func.count(models.IncomingActivity.id)).where(*where)
    )
    if q_count > 0:
        logger.info(f"{q_count} outgoing activities ready to process")
    if not q_count:
        # logger.debug("No activities to process")
        return False

    next_activity = (
        await db_session.execute(
            select(models.IncomingActivity)
            .where(*where)
            .limit(1)
            .order_by(models.IncomingActivity.next_try.asc())
        )
    ).scalar_one()

    next_activity.tries = next_activity.tries + 1
    next_activity.last_try = now()

    try:
        await save_to_inbox(
            db_session,
            next_activity.ap_object,
            next_activity.sent_by_ap_actor_id,
        )
    except Exception:
        logger.exception("Failed")
        next_activity.error = traceback.format_exc()
        _set_next_try(next_activity)
    else:
        logger.info("Success")
        next_activity.is_processed = True

    await db_session.commit()
    return True


async def loop() -> None:
    async with async_session() as db_session:
        while 1:
            try:
                await process_next_incoming_activity(db_session)
            except Exception:
                logger.exception("Failed to process next incoming activity")
                raise

            await asyncio.sleep(1)


if __name__ == "__main__":
    asyncio.run(loop())
