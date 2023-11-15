$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $remoteport = $matches[0];
} else{
  echo "IP �ּҸ� ã�� �� �����ϴ�.";
  exit;
}

#[Ports]
#�⺻ ������ ��Ʈ, 80, 443, 5000, 22, 3390
$ports=@(80,443,5000,22,3390);

#[Static ip]
#���� IP ���� ( �ǵ��� ������ )
$addr='0.0.0.0';
$ports_a = $ports -join ",";

#��ȭ�� �������� ����
iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";

# ��ȭ�� �� �߰�
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
}
Invoke-Expression "netsh interface portproxy show v4tov4";