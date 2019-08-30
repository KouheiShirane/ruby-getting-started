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
                if event.message["text"] =~ /砂丘/
                   message = [
                       {
                       type: "text",
                       text: ["いいえ、砂丘はありません。","島根にはないって言ってるでしょうが!!"].shuffle.first
                   }
                   ]
               elsif event.message["text"] == "島根です。"
               image_url =  "https://izumo-umaimono-ichiba.jp/syohinsetumei_image/04/2017041411270818923.jpg"
                   message = [
                       {
                       type: "text",
                       text: "島根にようこそ!!"
                   },
                   {
                        type: "image",
                        originalContentUrl: image_url,
                        previewImageUrl: image_url
                       }
                   ]
                elsif event.message["text"] =~ /キーワード/
                   message = [
                       {
                       type: "text",
                       text: "これを送ってもらえれば僕が反応します。
・自己紹介
・旅行
・島根
・た〜か〜の〜つ〜め〜
他にも適当に話しかけると反応するので遊んでください。
わからなくなったら「キーワード」でもう一度教えます。

「砂丘」とか言わないでくださいよ…？"
                   }
                   ]
                    elsif event.message["text"] =~ /島根/
                   message = [
                       {
                       type: "text",
                       text: ["いいえ、砂丘はありません。",
                       "どうでもいい県第１位になった県ですよ。",
                       "私立大学はありませんよ？",
                       "労働時間ランキング47位!働き方改革進んでます!",
                       "もっともどこにあるかわからない県ですよ"].shuffle.first
                   }
                   ]
                elsif event.message["text"] =~ /旅行/
                   message = [
                       {
                       type: "text",
                       text: ["島根に行きましょう!!","鳥取なんかより島根の方が楽しいですよ!!"].shuffle.first
                   }
                   ]
               elsif event.message["text"] =~ /自己紹介/
               image_url =  "https://blog-imgs-19.fc2.com/a/p/g/apg/taka1-18.jpg"
                 message = [
                     {
                         type: "text",
                         text: "こんにちは島根の吉田です。本名は吉田“ジャスティス”カツヲ21歳です。
誕生日は7月27日。
鷹の爪団の戦闘主任で、怪人製造マシン完成後は怪人製造の担当主任も務めています。
島根県庁からは「しまねSuper大使」に任命されました。よろしくお願いします。"
                     },
                      {
                        type: "image",
                        originalContentUrl: image_url,
                        previewImageUrl: image_url
                       }
                     ]
                     elsif event.message["text"] =~ /アニメ/
                     message = [
                       {
                       type: "text",
                       text: ["僕ってアニメ出てるんですよ？",
                       "僕のアニメを見てください!!
https://www.youtube.com/watch?v=VvvSfLFGyws"].shuffle.first
                   }
                   ]
                else
                 message = [
                     {
                   type: "text",
                   text:  ["島根は鳥取の左側です",
                            "た〜か〜の〜つ〜め〜",
                            "上司だからっていい気になりやがって…バカ野郎!!",
                            "島根ではよくあることです",
                            "島根には世界遺産があると言っても信じてもらえません…",
                            "島根なら人が少ないのでドローン飛ばしても怒られません"
                            ].shuffle.first
                 }
                 ]
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