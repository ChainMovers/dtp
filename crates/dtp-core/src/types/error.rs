//use sui_sdk::types::{ObjectID, SuiAddress};
use anyhow;
//use std::backtrace::Backtrace;
use core::option::Option;
use sui_sdk::types::error::SuiError;
use thiserror;

#[derive(Debug, thiserror::Error)]
#[allow(clippy::large_enum_variant)]
pub enum DTPError {
    #[error("Object ID not found")]
    ObjectIDNotFound,

    #[error("DTP Failed Move host create({client:?}). Info from sui_sdk-> {inner:?}")]
    FailedMoveHostCreate { client: String, inner: String },

    #[error(
        "DTP Failed RPC get_objects_owned_by_address({client:?}). Info from sui_sdk-> {inner:?}"
    )]
    FailedRPCGetObjectsOwnedByClientAddress { client: String, inner: String },

    // Terminated. Will need to re-create/re-open.
    #[error("Package ID not found")]
    PackageIDNotFound,

    #[error("Object ID not found")]
    TestHelperObjectNotFound,

    #[error("Not yet implemented. Need it? Ask for it on DTP Discord (Not Sui Discord).")]
    NotImplemented,

    #[error("DTP inner SuiError {0:?}")]
    InnerSuiError(#[from] SuiError),

    #[error("DTP inner anyhow::Error {0:?}")]
    InnerAnyhowError(#[from] anyhow::Error),
}

pub struct MoreInfo {
    pub fix_caller_into_dtp_api: bool,
    pub internal_err_report_to_devs: bool,
}

// DTP API uses always anyhow::Error.
//
// Actioneable info for the API user are obtain through
// functions provided here.
//
// This information is displayed by anyhow AND provided
// here for customized error handling.

pub fn get_more_info(err: anyhow::Error) -> Option<MoreInfo> {
    // Try to downcast to DTPError and match
    // the logic to build the MoreInfo.
    match err.downcast::<DTPError>() {
        Ok(dtp_err) => dtp_err.more_info(),
        Err(_anyhow_error) => None,
    }
}

impl DTPError {
    pub fn more_info(&self) -> Option<MoreInfo> {
        match self {
            DTPError::ObjectIDNotFound => Some(MoreInfo {
                fix_caller_into_dtp_api: false,
                internal_err_report_to_devs: false,
            }),
            _ => None,
        }
    }
}
