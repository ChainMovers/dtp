// A Pipes is a uni-directional data stream.
//   
// It is own by the endpoint transmiting data.
//
// Used only for simple transaction (no consensus).
// 
module dtp::pipe {
    use std::vector::{Self};
    use sui::object::{Self, UID, ID, uid_to_address, id_from_address};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    #[test_only]
    friend dtp::test_pipe;
    friend dtp::transport_control;

    #[test_only]
    friend dtp::test_transport_control;

    struct Pipe has key {
        id: UID,

        byte_payload_sent: u64,
        byte_header_sent: u64,
        send_call_completed: u64,
    }

    public(friend) fun create_internal( ctx: &mut TxContext ): ID {
        let pipe = Pipe {
            id: object::new(ctx),
            byte_payload_sent: 0,
            byte_header_sent: 0,
            send_call_completed: 0 
        };
        let id_copy = id_from_address(uid_to_address(&pipe.id));
        transfer::transfer(pipe, tx_context::sender(ctx));
        id_copy
    }

    public(friend) fun delete( self: Pipe ) {
        let Pipe { id, byte_payload_sent: _, byte_header_sent: _, send_call_completed: _ } = self;
        object::delete(id);
    }

    public entry fun send(
        self: &mut Pipe,
        data: vector<u8>,
        _control_byte: u8,
        _ctx: &mut TxContext )
    {
        // TODO Create NFT, emit event etc...

        // Sending of the inband control_byte...
        self.byte_header_sent = self.byte_header_sent + 1; 

        // Sending of the data...
        self.byte_payload_sent = self.byte_payload_sent + vector::length<u8>(&data);

        self.send_call_completed = self.send_call_completed + 1;
    }

}

module dtp::test_pipe {}
