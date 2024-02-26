module dtp::conn_objects {
  // === Imports ===
    use std::vector;

  // === Friends ===
    friend dtp::api_impl;
    friend dtp::host;
    friend dtp::transport_control;
    friend dtp::pipe;
    friend dtp::inner_pipe;

  // === Errors ===

  // === Constants ===

  // === Structs ===
    struct ConnObjects has drop, copy, store {    
      // References to all objects needed to exchange data 
      // through a connection.
      //
      // If an end-point loose these references, they can be
      // re-discovered using one of the related Host object.
      tc: address, // TransportControl
      cli_tx_pipe: address,
      srv_tx_pipe: address,
      cli_tx_ipipes: vector<address>,
      srv_tx_ipipes: vector<address>,
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
    public(friend) fun new(): ConnObjects {
        ConnObjects{
            tc: @0x0,
            cli_tx_pipe: @0x0,
            srv_tx_pipe: @0x0,
            cli_tx_ipipes: vector::empty(),
            srv_tx_ipipes: vector::empty(),
        }
    }

    public(friend) fun set_tc(self: &mut ConnObjects, tc: address) {
        self.tc = tc;
    }

    public(friend) fun set_cli_tx_pipe(self: &mut ConnObjects, cli_tx_pipe: address) {
        self.cli_tx_pipe = cli_tx_pipe;
    }

    public(friend) fun set_srv_tx_pipe(self: &mut ConnObjects, srv_tx_pipe: address) {
        self.srv_tx_pipe = srv_tx_pipe;
    }

    public(friend) fun add_cli_tx_ipipe(self: &mut ConnObjects, cli_tx_ipipe: address) {
        vector::push_back(&mut self.cli_tx_ipipes, cli_tx_ipipe);
    }

    public(friend) fun add_srv_tx_ipipe(self: &mut ConnObjects, srv_tx_ipipe: address) {
        vector::push_back(&mut self.srv_tx_ipipes, srv_tx_ipipe);
    }

  // === Private Functions ===

  // === Test Functions ===  

}