module vord

import eb
import json

fn handle_events(mut client Client, event_func_name string, packet string) ? {
	match event_func_name {
		'on_ready' {
			mut data := json.decode(Ready, packet) ?
			data.session_id = client.sid
			client.events.publish(event_func_name, client, data)
		}
		'on_message_create' {
			mut data := json.decode(Message, packet) ?
			client.events.publish(event_func_name, client, data)
		}
		'on_raw' {
			mut data := json.decode(Raw, packet) ?
			client.events.publish(event_func_name, client, data)
		}
		else {}
	}
}

pub fn (mut client Client) on(event string, handler eb.EventHandlerFn) {
	client.events.subscribe('on_$event', handler)
}
