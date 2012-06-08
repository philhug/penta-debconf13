BEGIN TRANSACTION;
GRANT SELECT ON debconf.dc_debian_role TO readonly;
GRANT SELECT ON debconf.dc_debconf_role TO readonly;
COMMIT TRANSACTION;
