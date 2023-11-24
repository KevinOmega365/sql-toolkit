
/*
 *  Copy Role Member Domain access (additive)
 */

DECLARE @fromLogin NVARCHAR(128) = 'from.this.user@foo.bar'
DECLARE @toLogin NVARCHAR(128) = 'to.this.user@baz.qux'

-- -- INSERT INTO dbo.stbl_System_RolesMembers (
-- --     RoleID,
-- --     Login
-- -- )
-- SELECT
--     RoleID,
--     @toLogin
-- FROM dbo.stbl_System_RolesMembers FromUser WITH (NOLOCK)
-- WHERE
--     Login LIKE @fromLogin
--     AND NOT EXISTS (
--         SELECT *
--         FROM
--             dbo.stbl_System_RolesMembers ToUser WITH (NOLOCK)
--         WHERE
--             Login = @toLogin
--             AND ToUser.RoleID = FromUser.RoleID
--     )

-- -- INSERT INTO dbo.stbl_System_RolesMembersDomains (
-- --     Domain,
-- --     RoleID,
-- --     Login
-- -- )
-- SELECT
--     Domain,
--     RoleID,
--     @toLogin
-- FROM dbo.stbl_System_RolesMembersDomains AS FromUser WITH (NOLOCK)
-- WHERE
--     Login LIKE @fromLogin
--     AND NOT EXISTS (
--         SELECT *
--         FROM
--             dbo.stbl_System_RolesMembersDomains ToUser WITH (NOLOCK)
--         WHERE
--             Login = @toLogin
--             AND ToUser.RoleID = FromUser.RoleID
--             AND ToUser.Domain = FromUser.Domain
--     )
