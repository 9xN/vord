import vord

fn main() {
	mut conf := vord.Config{
		token: "ur token here lol",
	}
	mut client := vord.new(mut &conf) ?
	client.on("ready", on_ready)
	client.on("message_create", on_message)
	client.login() ?
}
fn on_ready(mut client &vord.Client, mut event &vord.Ready) {
  	println("Ready")
}

fn on_message(mut client &vord.Client, mut message &vord.Message){
    if message.content == '!ping' {
        client.channel_create_message(message.channel_id, vord.MessagePayload{
            content: 'Pong!',
            embeds: [
                vord.MessageEmbed{
                    title: 'Hello World',
                    color: 0x7289da,
                    description: 'This is a test'
                }
            ]
        }) or {}
    }
}