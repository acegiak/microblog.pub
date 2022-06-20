import app  # noqa: F401  # here to init the backend
from microblogpub.core.activitypub import _actor_hash
from microblogpub.core.shared import MY_PERSON
from microblogpub.core.shared import p
from microblogpub.core.tasks import Tasks
from microblogpub.utils.local_actor_cache import is_actor_updated

h = _actor_hash(MY_PERSON, local=True)
if is_actor_updated(h):
    Tasks.send_actor_update()

p.push({}, "/task/cleanup", schedule="@every 1h")
