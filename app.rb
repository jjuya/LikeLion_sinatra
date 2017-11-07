require 'sinatra'
# http://www.sinatrarb.com/intro-ko.html

require 'httparty'
require 'nokogiri'

require 'uri'
require 'date'

require 'csv'

get '/' do
    send_file 'index.html'
end

get '/welcome' do
    "welcome!"
end



get '/lunch' do
    lunch = ["20층", "김밥까페", "빵", "순남시레기"]
    
    photos = {
                "20층" => "https://scontent-sea1-1.cdninstagram.com/t51.2885-15/s480x480/e35/20987024_1431422050287339_2004189507347283968_n.jpg?ig_cache_key=MTU4NzUwMTg2NjEwNzc3MTI0Nw%3D%3D.2",
                "김밥까페" => "http://news.naeil.com/AttachFile/PREV/2016/01/10/00069092_P.jpg",
                "빵" => "http://www.thefirstmedia.net/ko/wp-content/uploads/2016/01/%ED%81%AC%EA%B8%B0%EB%B3%80%ED%99%98_1-640x480.jpg",
                "순남시레기" => "http://soonnam.com/m/img/main/banner03.jpg"
             }
             
    # 2.4.0 :003 > {}.respond_to?(:sample)
    #  => false 
    
    @menu = lunch.sample()
    @photo = photos[@menu]
    
    erb :lunch
end
# 1.lunch menu를 추천해주도록 한다.
#     send_file 'lunch.html'
# 2.해당하는 점심메뉴의 이미지도 뿌려주도록 한다. 
    # file하나를 새로 만든다. lunch.html




get '/lotto' do
    @lotto = (1..45).to_a.sample(6)
    erb :lotto
end
# reload할 때 마다 새로운 lunch 메뉴가 나온다.

# lol 전적 검색
get '/lol' do
    erb :lol
end

# op.gg 전적 검색 정보를 스크래핑
get '/search' do
    # params = sinatra가 제공하는 빈 hash
    # @keyword = params[:userName]
    # "#{@keyword}"
    
    # 스크래핑 코드 테스트
    # res = HTTParty.get("http://www.op.gg/summoner/userName=system+in")
    # "#{res}"

    # text = Nokogiri::HTML(res.body)
    # "#{text}"
    
    # result = text.css("#SummonerLayoutContent > div.tabItem.Content.SummonerLayoutContent.summonerLayout-summary > div.SideContent > div.TierBox.Box > div.SummonerRatingMedium > div.TierRankInfo > div.TierInfo > span.WinLose > span.wins")

    # "#{result.text}"
    
    # 스크래핑 추가
    url = "http://www.op.gg/summoner/userName="
    
    # URL encode : https://stackoverflow.com/questions/17375947/parsing-string-to-add-to-url-encoded-url
    # global substitution : gsub("원래 글자", "바꿀 글자")
    @id = params[:userName].gsub(" ", "+")
    @keyword = URI.encode(params[:userName])
    
    res = HTTParty.get(url + @keyword)
    
    text = Nokogiri::HTML(res.body)
    
    
    @win = text.css("span.wins").text
    @loss = text.css("span.losses").text
   
    # "#{win.text}"
    
    # log 남기기
    # a+ : append
    
    # File.open("log.txt", 'a+') do |f|
    #     f.write("#{@id}, #{@win}, #{@loss}," + Time.now.to_s + "\n")
    # end
    
    # cf. http://ruby-doc.org/stdlib-2.0.0/libdoc/csv/rdoc/CSV.html
    CSV.open('log.csv', 'a+') do |csv|
        csv << [@id, @win, @loss, Time.now.to_s]
    end
    
    erb :search
end

get '/log' do
    @log = []
    
    CSV.foreach('log.csv') do |row|
        # [[...., ...., ...]]
        @log << row

    end
    
    erb :log
end

# 사용자에게 이름을 출력해주는 
get '/welcome/:name' do
    # "welcome! " + :name
    "Welcome! #{params[:name]}"
end


# 사용자에게 3제곱을 출력해준다.

get '/cube/:num' do
    input = params[:num].to_i
    result = input ** 3
    "The result is #{result}"
end

 # "#{params[:num]}의 세제곱= " + params[:num].to_i ** 3