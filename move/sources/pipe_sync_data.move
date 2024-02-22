// PipeSyncData object
//
// Data that flows from InnerPipe -> Pipe -> TransportControl -> Host
// The data is aggregated as it flows toward Host.
//
#[allow(unused_field, unused_use)]
module dtp::pipe_sync_data {

  // === Imports ===

  // === Friends ===
    friend dtp::host;
    friend dtp::transport_control;
    friend dtp::pipe;
    friend dtp::inner_pipe;

    #[test_only]
    friend dtp::tests_pipe_sync_data;

  // === Errors ===

  // === Constants ===

  // === Structs ===
    struct PipeSyncData has copy, store, drop {
        byte_payload_sent: u64,
        byte_header_sent: u64,
        send_call_completed: u64,
        // TODO Req/Resp sequence tracking.
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
    public(friend) fun new(): PipeSyncData {
        PipeSyncData {
            byte_payload_sent: 0,
            byte_header_sent: 0,
            send_call_completed: 0,
        }
    }

    public(friend) fun merge(self: &mut PipeSyncData, b: &PipeSyncData) {
        self.byte_payload_sent = self.byte_payload_sent + b.byte_payload_sent;
        self.byte_header_sent = self.byte_header_sent + b.byte_header_sent;
        self.send_call_completed = self.send_call_completed + b.send_call_completed;
    }

  // === Private Functions ===

  // === Test Functions ===  
}            
