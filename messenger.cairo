#[contract]
mod Messenger {
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::felt::{felt252, felt64};

    struct Message {
        sender: ContractAddress,
        content: felt252,
        timestamp: felt64,
    }

    static mut messages: Vec<Message> = Vec::new();

    #[event]
    fn MessageSent(sender: ContractAddress, content: felt252, timestamp: felt64) {}

    #[event]
    fn MessageReceived(sender: ContractAddress, content: felt252, timestamp: felt64) {}

    #[external]
    fn Send_Message(content: felt252) {
        let sender = get_caller_address();
        let timestamp = starknet::block_timestamp();
        let message = Message {
            sender,
            content,
            timestamp,
        };
        messages.push(message.clone());

        MessageSent(sender, content, timestamp);
    }


    #[view]
    fn Get_Messages() -> Vec<Message> {
        let caller = get_caller_address();
        let mut received_messages: Vec<Message> = Vec::new();

        for message in messages.iter() {
            if message.sender == caller {

                MessageReceived(message.sender, message.content, message.timestamp);
                received_messages.push(message.clone());
            }
        }

        received_messages
    }

    #[external]
    fn Clear_Messages() {
        let caller = get_caller_address();

        if caller == ContractAddress::default() {

            messages.clear();
        }
    }
}
