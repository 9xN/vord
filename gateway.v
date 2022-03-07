module vord

import net.websocket
import json
import time

const default_gateway = 'wss://gateway.discord.gg/?v=9&encoding=json'

struct GatewayPacket {
	op byte   [required]
	d  string [raw]
	s  u32    [required]
	t  string
}

struct HelloPacket {
	heartbeat_interval u32 [required]
}

struct Resume {
	token string  [required]
	session_id string [required]
	seq       int    [required]
}
struct Identify {
	token      string             [required]
	properties IdentifyProperties [required]
}

struct IdentifyProperties {
	os      string [json: '\$os']
	browser string [json: '\$browser']
	device  string [json: '\$device']
}

fn gateway_respond(mut ws websocket.Client, op byte, data string) ? {
	ws.write_string('{"op":$op,"d":$data}') ?
}

pub fn create_ws(mut client &Client) ? {
	client.ws = websocket.new_client(default_gateway) ?
	client.ws.on_message_ref(ws_on_message, client)
	client.ws.on_close_ref(ws_on_close, client)
}

fn ws_on_close(mut ws websocket.Client, reason int, message string, mut client &Client) ? {
	lock client.hb {
		if client.hb.is_open {
			client.hb.is_open = false
			client.hb_thread.wait() ?
		}
	}
}

fn ws_on_message(mut ws websocket.Client, msg &websocket.Message, mut client &Client) ? {
	if msg.opcode != .text_frame {
		return
	}

	payload_string := msg.payload.bytestr()
	packet := json.decode(GatewayPacket, payload_string) ?

	if packet.s != 0 {
		client.seq = packet.s
	}

	match Op(packet.op) {
		.dispatch {
			event_func_name := 'on_$packet.t.to_lower()'

			// also dispatch as raw event
			handle_events(mut client, 'on_raw', payload_string) ?
			handle_events(mut client, event_func_name, packet.d) ?
		}
		.hello {
			hello := json.decode(HelloPacket, packet.d) ?
           if client.resuming == true {
			   mut resume := Resume {
				   token: client.token,
				   session_id: client.sid,
				   seq: int(client.seq)
			   }

			   gateway_respond(mut &ws, 6, json.encode(resume)) ?
		   }
			identify_packet := Identify{
				token: client.token
				properties: IdentifyProperties{
					os: 'Linux'
					browser: 'github/9xN'
					device: 'vord'
				}
			}

			gateway_respond(mut &ws, 2, json.encode(identify_packet)) ?

			lock client.hb {
				client.hb.is_open = true
			}

			client.hb_thread = go client.hb_proc(hello.heartbeat_interval * time.millisecond)
		}
		.heartbeat_ack {
			if client.hb_last != 0 {
				client.latency = u32(time.now().unix - client.hb_last)
			}
		}

		.reconnect {
			client.resuming = true
			client.ws.close(1000, 'Reconnect') ?
		}
		else {}
	}
}
