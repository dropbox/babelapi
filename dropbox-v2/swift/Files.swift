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
