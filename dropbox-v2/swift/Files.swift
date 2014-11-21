import Foundation

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

// MARK: - Router

extension Router {
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

// MARK: - Client

extension Client {

    public func download(path: String, rev: String? = nil, range: Range<Int>? = nil, destination: (NSURL, NSHTTPURLResponse) -> (NSURL), progress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (Result<NSURL>) -> Void) {
        manager.download(Router.FilesAndMetadata.Get(root: root, path: path, rev: rev, range: range), destination: destination)
            .validate()
            .response { (request, response, URL, error) -> Void in
//            completionHandler(URL != nil ? Result<NSURL>.Success(URL! as NSURL) : Result<NSURL>.Failure)
            }
    }

    // TODO: Transparently use chunked upload if payload is over maximum
    public func upload(path: String, file: NSURL, overwrite: Bool? = nil, parentRev: Rev? = nil, progress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (Result<Metadata>) -> Void) {
        upload(path, stream: NSInputStream(URL: file)!, overwrite: overwrite, parentRev: parentRev, progress: progress, completionHandler: completionHandler)
    }

    public func upload(path: String, data: NSData, overwrite: Bool? = nil, parentRev: Rev? = nil, progress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (Result<Metadata>) -> Void) {
        upload(path, stream: NSInputStream(data: data), overwrite: overwrite, parentRev: parentRev, progress: progress, completionHandler: completionHandler)
    }

    private func upload(path: String, stream: NSInputStream, overwrite: Bool? = nil, parentRev: Rev? = nil, progress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (Result<Metadata>) -> Void) {
        manager.upload(Router.FilesAndMetadata.Put(root: root, path: path, overwrite: overwrite, parentRev: parentRev, locale: locale), stream: stream)
            .progress(closure: progress)
            .responseResult(completionHandler)
    }

    // TODO: Fix relationship between path and metadata
    public func metadata(path: String, fileLimit: Int? = nil, hash: String? = nil, list: Bool? = nil, includeDeleted: Bool? = nil, rev: Rev? = nil, completionHandler: (Result<Metadata>) -> Void) {
        manager.request(Router.FilesAndMetadata.Metadata(root: root, path: path, fileLimit: fileLimit, hash: hash, list: list, includeDeleted: includeDeleted, rev: rev, locale: locale))
            .validate()
            .responseResult(completionHandler)
    }
}
