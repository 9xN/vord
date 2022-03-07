module rest

import net.http
pub struct Rest {
pub mut:
     token string
	 user_agent string
}

pub fn new(token string) Rest {
  mut rest := Rest{
	  token: token,
	  user_agent: 'vord client made by github/9xN'
  }

  return rest
}

pub fn (mut r Rest) post(url string, data string) ?http.Response {
    mut config := http.FetchConfig{
		url: "$url",
		method: .post,
		header:  http.new_header_from_map({
			.authorization: "$r.token",
			.content_type:  'application/json',
			.user_agent:    r.user_agent
		}),
		data: data
	}

	mut resp := http.fetch(config) ?
	return resp
}

pub fn (mut r Rest) get(url string) ?http.Response {
	 mut config := http.FetchConfig{
		url: "$url",
		method: .get,
		header:  http.new_header_from_map({
			.authorization: "$r.token",
			.content_type:  'application/json',
			.user_agent:    r.user_agent
		})
	}

	mut resp := http.fetch(config) ?

	return resp
}

pub fn (mut r Rest) patch(url string, data string) ?http.Response {
	mut config := http.FetchConfig{
		url: "$url",
        method: .patch,
		header: http.new_header_from_map({
			.authorization: "$r.token",
			.content_type:  'application/json',
			.user_agent:    r.user_agent
		})
	}

	mut resp := http.fetch(config) ?
   println(resp) 
   return resp
}

pub fn (mut r Rest) delete(url string) ? {
	mut config := http.FetchConfig{
		url: "$url",
		method: .delete,
		header: http.new_header_from_map({
			.authorization: "$r.token",
			.content_type:  'application/json',
			.user_agent:    r.user_agent
		})
	}

	http.fetch(config) ?
}
