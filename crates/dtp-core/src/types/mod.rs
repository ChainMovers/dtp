// Flatten many sub modules/files under the same dtp_core::types module.
//
// Allows to do:
//    use dtp_core::types::{DTPError, SomethingElseInFuture}
//
// Instead of verbose:
//    use dtp_core::types::error::DTPError;
//    use dtp_core::somethingelseinfuture::SomethingElseInFuture;
pub use self::error::*;

pub mod error;
