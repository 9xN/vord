module vord

import rest
import x.json2
import json

pub fn (mut client Client) channel_create_message(channel_id string, data MessagePayload) ?Message {
        mut payload := map[string]json2.Any{}
        payload['content'] = data.content
        payload['tts'] = data.tts
        payload['embeds'] = data.embeds.to_json()
        mut resp := client.rest.post(rest.endpoint_channel_message(client.http_endpoint, channel_id), payload.str()) ?
    
       mut msg_ob := json.decode(Message, resp.text) ? 

       return msg_ob

}

pub fn (mut client Client) channel_edit_message(channel_id string, message_id string, data MessagePayload) ?Message {
        mut payload := json.encode(data)
        println(payload)
     mut resp := client.rest.patch(rest.endpoint_edit_channel_message(client.http_endpoint, channel_id, message_id), payload) ?

     mut msg_ob := json.decode(Message, resp.text) ?

     return msg_ob
}
pub fn (mut client Client) get_channel(c_id string) ?Channel {
        mut resp := client.rest.get(rest.endpoint_channel(client.http_endpoint, c_id)) ?

        return json.decode(Channel, resp.text)
}

pub fn (mut client Client) guild_channel_create(guild_id string, data CreateChannelData) ? {
        mut payload := json.encode(data)	
       client.rest.post(rest.endpoint_guild_channels(client.http_endpoint, guild_id), payload) ?
}

pub fn (mut client Client) channel_edit(channel_id string, data ChannelEditData) ? {
    mut payload := json.encode(data)

     client.rest.patch(rest.endpoint_channel(client.http_endpoint, channel_id), payload) ?

}

pub fn (mut client Client) channel_delete(channel_id string) ? {
        client.rest.delete(rest.endpoint_channel(client.http_endpoint, channel_id)) ? 
}