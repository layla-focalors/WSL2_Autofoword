$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $remoteport = $matches[0];
} else{
  echo "IP 주소를 찾을 수 없습니다.";
  exit;
}

#[Ports]
#기본 포워딩 포트, 80, 443, 5000, 22, 3390
$ports=@(80,443,5000,22,3390);

#[Static ip]
#고정 IP 설정 ( 건들지 마세요 )
$addr='0.0.0.0';
$ports_a = $ports -join ",";

#방화벽 접근제어 해제
iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";

# 방화벽 룰 추가
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
}
Invoke-Expression "netsh interface portproxy show v4tov4";