import Foundation

struct Router {
    enum Users {
        ///
        case Info(accountId: AccountID)

        ///
        case InfoMe
    }

    enum Files {
        /// Download a file in a user's Dropbox.
        case Download(FileTarget)
        /*
        case Download(path: String, rev: String)
        */

        /// Start an upload session.
        case UploadStart

        // NOTE: Documentation for UploadAppend route is duplicate of UploadStart
        /**
        Start an upload session. [sic]

        :param: upload_id Identifies the upload session to append data to.
        :param: offset The offset into the file of the current chunk of data being uploaded. It can also be thought of as the amount of data that has been uploaded so far. We use the offset as a sanity check.
        */
        case UploadAppend(uploadID: String, offset: UInt64)

        /**
        Use this endpoint to either finish an ongoing upload session that was begun with :route:`UploadStart` or upload a file in one shot.

        :param: path Path in the user's Dropbox to save the file.
        :param: mode The course of action to take if a file already exists at :field:`path`.
        :param: appendTo If specified, the current chunk of data should be appended to an existing upload session.
        :param: autorename Whether the file should be autorenamed in the event of a conflict.
        :param: clientModifiedUTF Self-reported time of when this file was created or modified.
        :param: mute Whether the devices that the user has linked should notify them of the new or updated file.
        */
        case Upload(path: String, mode: ConflictPolicy, appendTo: String?, autorename: Bool?, clientModifiedUTC: UInt64?, mute: Bool?)

        /// Returns the contents of a folder.
        case GetMetadata(FileTarget)
    }
}
