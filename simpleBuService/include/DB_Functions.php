<?php
    header('Content-type:text/html;charset=utf-8');
    
    
    //配置您申请的appkey
class DB_Functions {

    private $db;

    //put your code here
    // constructor
    function __construct() {
        require_once 'DB_Connect.php';
        // connecting to database
        $this->db = new DB_Connect();
        $this->db->connect();
    }

    // destructor
    function __destruct() {
        
    }
    
    public function getLuckInfo($name,$week) {
        $appkey = "91611110023647e3d0d736a8709c1729";

        
        $url = "http://web.juhe.cn:8080/constellation/getAll";
        $params = array(
                        "key" => $appkey,//应用APPKEY(应用详细页查询)
                        "consName" => $name,//星座名称，如:白羊座
                        "type" => $week,//运势类型：today,tomorrow,week,nextweek,month,year
                        );
        $paramstring = http_build_query($params);
        $opts = array('http'=>array('header' => "User-Agent:MyAgent/1.0\r\n"));
        $context = stream_context_create($opts);
        $jsonData = file_get_contents($url.'?'.$paramstring,false,$context);
        $json_result = json_decode($jsonData,true);

        $startTime = explode('-', $json_result['date'])[0];
        $endTime = explode('-', $json_result['date'])[1];
        
        
        $response["start_date"] = $startTime;
        $response["end_date"] = $endTime;
        $response["week"] = $json_result['weekth'];
        $response["content"] = explode('财运：', $json_result['money'])[1];
        $response["name"] = $json_result['name'];
        
       $result = $this->saveDB($response["name"],$response["content"],$response["week"],$response["start_date"],$response["end_date"]);
        
//        $file_contents = file_get_content($url.'?'.$paramstring);
//        return($jsonData);

//        $content = juhecurl($url,$paramstring);

//        $json_result = json_decode($jsonData,true);
        if($result === "exsit")
        {
            return "exsit";
        }else
            if($result)
        {
            return $response;
        }else
        {
            return false;
        }

    }
    
    //**************************************************
    
    /**
     * 请求接口返回内容
     * @param  string $url [请求的URL地址]
     * @param  string $params [请求的参数]
     * @param  int $ipost [是否采用POST形式]
     * @return  string
     */
    function juhecurl($url,$params=false,$ispost=0){
        $httpInfo = array();
        $ch = curl_init();

        curl_setopt( $ch, CURLOPT_HTTP_VERSION , CURL_HTTP_VERSION_1_1 );
        curl_setopt( $ch, CURLOPT_USERAGENT , 'JuheData' );
        curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT , 60 );
        curl_setopt( $ch, CURLOPT_TIMEOUT , 60);
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER , true );
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
       

        if( $ispost )
        {
            curl_setopt( $ch , CURLOPT_POST , true );
            curl_setopt( $ch , CURLOPT_POSTFIELDS , $params );
            curl_setopt( $ch , CURLOPT_URL , $url );
        }
        else
        {
            if($params){
                curl_setopt( $ch , CURLOPT_URL , $url.'?'.$params );
            }else{
                curl_setopt( $ch , CURLOPT_URL , $url);
            }
        }
        $response = curl_exec( $ch );

        if ($response === FALSE) {
            //echo "cURL Error: " . curl_error($ch);
            return false;
        }
        $httpCode = curl_getinfo( $ch , CURLINFO_HTTP_CODE );
        $httpInfo = array_merge( $httpInfo , curl_getinfo( $ch ) );
        curl_close( $ch );
        return $response;
    }
    

    public function getTest($name) {
        $appkey = "91611110023647e3d0d736a8709c1729";

        return $appkey;

    }

    /**
     * Get product info
     */
    public function saveDB($name,$content,$week,$startDate,$endDate) {
        
        $result = mysql_query("SELECT * FROM luckInfo WHERE start_date = '$startDate' and name = '$name'") or die(mysql_error());
        $no_of_rows = mysql_num_rows($result);
        if ($no_of_rows > 0) {
            return "exsit";
        }else {
            // user not found
            $updateUserinfo = mysql_query("INSERT INTO luckInfo(name,start_date,end_date,week,content) VALUES ('$name', '$startDate', '$endDate','$week', '$content')") or die(mysql_error());
            if($updateUserinfo)
            {
                return true;
            }else
            {
                return false;
            }
        }
    }
}

?>
