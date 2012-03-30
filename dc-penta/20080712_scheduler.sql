BEGIN;
insert into auth.role values('scheduler');
insert into auth.role_permission(role,permission) values ('scheduler','modify_event');
insert into auth.role_permission(role,permission) values ('scheduler','pentabarf_login');
COMMIT;
