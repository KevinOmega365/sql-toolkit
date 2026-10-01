
-------------------------------------------------------------------------------

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Valhall -- '%'

-------------------------------------------------------------------------------

drop table if exists #ImportUpdates
drop table if exists #ImportMatching
drop table if exists #DcsMatching
drop table if exists #MatchingCounts

-------------------------------------------------------------------------------

declare @DomainList table (Domain nvarchar(128))
insert into @DomainList select distinct DCS_Domain
from dbo.ltbl_Import_DTS_DCS_Documents as D with (nolock)
where INTEGR_REC_GROUPREF like @groupRef

-------------------------------------------------------------------------------

/*
 * get the "UPDATED" records for the import
 */
select
    I.PrimKey,
    I.DCS_FileRef,
    S.CRC,
    I.DCS_Domain,
    I.DCS_DocumentID,
    I.DCS_RevisionItemNo
into
    #ImportUpdates
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles as I with (nolock)
    join dbo.stbl_System_Files S with (nolock)
        on S.PrimKey = I.DCS_FileRef
where
    INTEGR_REC_GROUPREF like @groupRef
    and INTEGR_REC_STATUS = 'UPDATED'

/*
 * get the FileRefs and CRC that match the updated from the import
 */
select
    IsTheUpdate =
    case
        when I.PrimKey = U.PrimKey
        then cast(1 as bit)
        else cast(0 as bit)
    end,
    I.PrimKey,
    I.DCS_Domain,
    I.DCS_DocumentID,
    I.DCS_RevisionItemNo,
    I.DCS_FileRef,
    S.CRC,
    I.DCS_Type,
    I.DCS_FileDescription
into
    #ImportMatching
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles as I with (nolock)
    join dbo.stbl_System_Files S with (nolock)
        on S.PrimKey = I.DCS_FileRef
    join #ImportUpdates U
        on I.DCS_Domain = U.DCS_Domain
        and I.DCS_DocumentID = U.DCS_DocumentID
        and I.DCS_RevisionItemNo = U.DCS_RevisionItemNo
        and (
            U.DCS_FileRef = I.DCS_FileRef
            or U.CRC = S.CRC
        )

/*
 * get the FileRefs and CRC that match the updated from DCS
 */
select
    RF.PrimKey,
    RF.Domain,
    RF.DocumentID,
    RF.RevisionItemNo,
    RF.FileRef,
    S.CRC,
    RF.Type, 
    RF.FileDescription
into
    #DcsMatching
from
    dbo.atbl_DCS_RevisionsFiles as RF with (nolock)
    join dbo.stbl_System_Files S with (nolock)
        on S.PrimKey = RF.FileRef
where
    exists (
        select *
        from
            #ImportMatching U
        where
            RF.Domain = U.DCS_Domain
            and RF.DocumentID = U.DCS_DocumentID
            and RF.RevisionItemNo = U.DCS_RevisionItemNo
            and (
                U.DCS_FileRef = RF.FileRef
                or U.CRC = S.CRC
            )
    )

/*
 * for each of the Document-Revisons get a list of the groups of files that can matchup
 */
select
    R.Domain,
    R.DocumentID,
    R.Revision,
    ImportFiles = (
        select count(*)
        from
            #ImportMatching U
        where
            R.Domain = U.DCS_Domain
            and R.DocumentID = U.DCS_DocumentID
            and R.RevisionItemNo = U.DCS_RevisionItemNo
    ),
    PimsFiles = (
        select count(*)
        from
            #DcsMatching U
        where
            R.Domain = U.Domain
            and R.DocumentID = U.DocumentID
            and R.RevisionItemNo = U.RevisionItemNo
    ),
    ImportFilesDetail = (
        select
            DCS_Type,
            DCS_FileDescription,
            CRC,
            DCS_FileRef
        from
            #ImportMatching U
        where
            R.Domain = U.DCS_Domain
            and R.DocumentID = U.DCS_DocumentID
            and R.RevisionItemNo = U.DCS_RevisionItemNo
        for
            json auto
    ),
    PimsFilesDetail = (
        select
            Type,
            FileDescription,
            CRC,
            FileRef
        from
            #DcsMatching U
        where
            R.Domain = U.Domain
            and R.DocumentID = U.DocumentID
            and R.RevisionItemNo = U.RevisionItemNo
        for
            json auto
    )
into
    #MatchingCounts
from
    #DcsMatching M
    join dbo.atbl_DCS_Revisions R with (nolock)
        on R.Domain = M.Domain
        and  R.DocumentID = M.DocumentID
        and  R.RevisionItemNo = M.RevisionItemNo
group by
    R.Domain,
    R.DocumentID,
    R.Revision,
    R.RevisionItemNo
order by
    R.Domain,
    R.DocumentID,
    R.Revision,
    R.RevisionItemNo

/*
 * get some markdown
 */
select
    Domain,
    DocumentID,
    Revision,
    ImportFiles,
    PimsFiles,
    ImportFilesDetail = json_query(ImportFilesDetail),
    PimsFilesDetail = json_query(PimsFilesDetail)
from
    #MatchingCounts
for
    json auto

-- select * from #DcsMatching
-- select * from #ImportMatching
-- select * from #ImportUpdates
