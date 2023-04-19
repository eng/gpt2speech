require "openai"
require "dotenv/load"
require "httparty"

client = OpenAI::Client.new(:access_token => ENV.fetch('OPENAI_ACCESS_TOKEN'))

prompt = "write a short (less than 30 seconds when read aloud) rhyming ode to tacos"

response = client.chat(
  :parameters => {
    :model => "gpt-3.5-turbo",
    :messages => [
      { :role => "user", :content => prompt }
    ]
  } 
)

puts "GPT returned: #{response.parsed_response.inspect}"
poem = response.parsed_response["choices"][0]["message"]["content"]

url = "https://api.elevenlabs.io/v1/text-to-speech/#{ENV.fetch("ELEVENLABS_VOICE_ID")}"
headers = {
  "Content-Type" => "application/json",
  "xi-api-key" => ENV.fetch("ELEVENLABS_API_KEY"),
  "accept" => "audio/mpeg"
}
response = HTTParty.post(url, :headers => headers, :body => { :text => poem }.to_json)

puts "ElevenLabs returned: #{response.parsed_response.inspect}"

File.open("output.mp3", "wb") do |f|
  f.write(response.parsed_response)
end
