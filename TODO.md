docker-devpi TODO
=================

Things to improve:

  ☑ Update from the old ``DEVPI_SERVERDIR`` to the new ``DEVPISERVER_SERVERDIR`` env var.

  ☑ Figure out how to set ``--secretfile`` so logins are valid across restarts.
Could be handy for cluster deployments. (Check :doc:`docker-entrypoint.sh <docker-entrypoint.sh>`
for short python script/hack, reverse engineered from the source code).

  ☐ Use devpi-gen-config?
