  class LinebotController < ApplicationController
     require "line/bot"  # gem "line-bot-api"
 
     # callbackアクションのCSRFトークン認証を無効
     protect_from_forgery :except => [:callback]
 
     def client
       @client ||= Line::Bot::Client.new { |config|
         config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
         config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
       }
     end
     
     def callback
       body = request.body.read
   
       signature = request.env["HTTP_X_LINE_SIGNATURE"]
       unless client.validate_signature(body, signature)
         error 400 do "Bad Request" end
       end
   
       events = client.parse_events_from(body)
   
       events.each { |event|
         case event
         when Line::Bot::Event::Message
           case event.type
           when Line::Bot::Event::MessageType::Text
               if event.message["text"] =~ "旅行"
                   message = [
                       {
                       type: "text",
                       text: "島根に行きましょう!!"
                   }
                   ]
               else
                 message = {
                   type: "text",
                   text:  ["島根は鳥取の左側です",
                            "た〜か〜の〜つ〜め〜",
                            "上司だからっていい気になりやがって…バカ野郎!!",
                            "島根ではよくあることです",
                            "島根には世界遺産があると言っても信じてもらえません…",
                            "島根県に来るならここを確認です。https://www.kankou-shimane.com"].shuffle.first
                 }
                end
             client.reply_message(event["replyToken"], message)
           when Line::Bot::Event::MessageType::Location
             message = {
               type: "location",
               title: "ここは島根ですか？",
               address: event.message["address"],
               latitude: event.message["latitude"],
               longitude: event.message["longitude"]
             }
             client.reply_message(event["replyToken"], message)
           end
         end
       }
   
       head :ok
     end
 end