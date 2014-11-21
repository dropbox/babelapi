import Foundation

// Files

struct PathTarget {
    // Path from root. Should be an empty string for root.
    let path: String
}

// NOTE: Again, uncertain how best to handle struct extensions
struct FileTarget {
    // Path from root. Should be an empty string for root.
    let path: String

    // Revision of target file.
    let rev: String?
}

// MARK: -

struct FileInfo {
    /// Name of file.
    let name: String
}

/// The action to take when a file path conflict exists.
enum ConflictPolicy {
    /// On a conflict, the upload is rejected.
    case Add

    /// On a conflict, the target is overridden.
    case Overwrite

    /// On a conflict, only overwrite the target if the parent_rev matches.
    case Update(String)
}

// MARK: -

/// A folder resource
struct Folder {

}

enum Metadata {
    ///
    case File

    ///
    case Folder
}

struct Entry {
    ///
    let metadata: Metadata

    ///
    let name: String
}

// MARK: -

public enum Result<T> {
    case Success(T)
    case Failure
}

struct FilesRouter {
    enum Routes {
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

    // TODO: (mattt) How to reconcile Babel spec from Swift / protocol-specific niceties like destination and progress?
    func download(path: String, rev: String, destination: (NSURL, NSHTTPURLResponse) -> (NSURL), progress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (Result<NSURL>) -> Void) {
        // ...
    }
}
