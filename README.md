# Messenger - Prokeep Interview Assignment

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Message queueing is processed in:
  `./lib/messenger/queue_pool.ex`

The `/receive-message` controller is in:
   `./lib/messenger_web/controllers/receive_message.ex`

The testing script is in:
    `./test/messenger_web/controllers/receive_message_test.exs`
    Run test with: `mix test`


Project Requirements:
  1.  You should have an HTTP endpoint at the path /receive-message which 
      accepts a GET request with the query string parameters queue (string)
      and message (string).

  2.  Your application should accept messages as quickly as they come in and 
      return a 200 status code.

  3.  Your application should "process" the messages by printing the message 
      text to the terminal, however for each queue, your application should 
      only "process" one message a second, no matter how quickly the messages 
      are submitted to the HTTP endpoint.

  4. Bonus points for writing some kind of test that verifies messages are only
     processed one per second.