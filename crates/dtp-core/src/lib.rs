// Most of the internal complexity related to DTP will move here (dtp-core) such
// that the dtp-sdk will remain a thin layer focusing on providing a simplified
// view to the user.
//
// That would also make possible one day to have an "alternative/advanced" API to
// co-exist.

// Dummy unused code for now.
pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
