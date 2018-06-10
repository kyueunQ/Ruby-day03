require 'sinatra'
require 'sinatra/reloader'
require 'uri'
#nokogiri와 하는 역할 같음.
require 'rest-client'
require 'nokogiri'


# 1. 연산하기
get '/calculate' do
    num1 = params[:n1].to_i
    num2 = params[:n2].to_i
    @sum = num1 + num2
    @min = num1 - num2
    @mul = num1 * num2
    @div = num1 / num2
    
    erb :calculate
end


get '/numbers' do
    erb :numbers 
end


# 2. 로그인 
get '/form' do
    erb :form
end

id = 'multi'
pw = 'campus'

post '/login' do
    if id.eql?(params[:id])
        # 비밀번호를 체크하는 로직
        if pw.eql?(params[:passwd])
            #무조건 get으로 response, 아래쪽에 get메소드로 선언했기 때문에
            redirect '/complete'
        else
            @msg = "비밀번호가 틀렸습니다."
            #새로운 url로 요청이 이루어지도록 설계
            #한번 요청이 다녀오면 서버와의 커넥션은 끊기기 때문에, 바로 위에서 @msg로 저장하여도 해당 메시지가 보이지 않음
            redirect '/error?err_co=2'
        end
    else
        # ID가 존재하지 않습니다.
        #@msg = "ID가 존재하지 않습니다."
        redirect '/error?err_co=1'
    end
end

#계정이 존재하지 않거나 비밀번호가 틀린 경우
get '/error' do
    #아이디 패스워드에 따라 나눠서 정보를 보여주도록 하는 경우
    if params[:err_co].to_i == 1
        @msg = "아이디가 존재하지 않습니다."
    elsif params[:err_co].to_i == 2
        @msg = "비밀번호가 틀렸습니다."
    end
    erb :error
end

#로그인 완료된 곳.
get '/complete' do
    erb :complete
end


# 3. google과 네이버 검색창 구현
# 첫번째 방법
get '/search' do
    erb :search
end

# 두번째 방법
post '/search' do
    puts params[:engine]
    case params[:engine]
    when "naver"
        redirect "https://search.naver.com/search.naver?query=#{params[:query]}"
    when "google"
        redirect "https://www.google.com/search?q=#{params[:q]}"
    end
end


# 4. crawling을 통해 정보 불러오기
get '/op_gg' do
    if params[:userName]
        case params[:search_method]
        
        when "self"
            # op.gg에서 승/패 수만 크롤링하여 보여줌
            # RestClient를 통해 op.gg에서 검색결과 페이지를 크롤링(HTTParty와 유사)
            url = RestClient.get(URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}"))
            
            # 검색결과 페이지 중에서 win / lose를 찾고 nokogiri를 통해 원하는 데이터만 가져옴
            result = Nokogiri::HTML.parse(url)
            # result.css("span.win")[0]도 가능
            win = result.css("span.win").first
            lose = result.css("span.lose").first
            
            # 검색결과를 페이지에서 보여주기 위한 변수 선언
            @win = win.text
            @lose = lose.text
            
        when "opgg"
            # 사이트로 연결
            #한국어 인식을 위해서 encoding
            url = URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}")
            redirect url
        end
    end
    
    erb :'op_gg'
end
