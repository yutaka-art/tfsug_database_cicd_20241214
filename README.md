# tfsug_database_cicd_20241214
TFSUG_Azure DevOpsオンライン Vol.12 ～ Database CI/CD

## 1. Azureコンポーネント作成
```powershell
# Azureへログイン
az login
az login --tenant <your tenant id>
az account show

# リソースグループ作成
az group create  --name <your resource group name> --location japaneast
# Bicepでコンポーネントを作成
az deployment group create --resource-group <your resource group name> --template-file deploy/main.bicep --parameters envFullName=eventattendees envShortName=eventattendees envTargetName=dev
```

|名前|種類|場所|
|--|--|--|
|app-eventattendees-dev-001|App Service|Japan East|
|appi-eventattendees-dev-001| Application Insights|Japan East|
|asp-eventattendees-dev-001| App Service プラン|Japan East|
|creventattendeesdev001| コンテナー レジストリ|Japan East|
|EventTrackerDB (sqleventattendeesdev001/EventTrackerDB)|SQL データベース|Japan East|
|Failure Anomalies - appi-eventattendees-dev-001| スマート検出機能アラート ルール|グローバル|
|kveventattendeesdev001| キー コンテナー|Japan East|
|log-eventattendees-dev-001| Log Analytics ワークスペース|Japan East|
|sqleventattendeesdev001| SQL Server|Japan East|
|steventattendeesdev001| ストレージ アカウント|Japan East|
|webappappeventattendeesdev001 (creventattendeesdev001/webappappeventattendeesdev001)|コンテナー レジストリ webhook|Japan East|

## 2. Azureコンポーネント調整
1. AzDO連携用のサービスプリンシパルを作成
2. リソースグループへ[1]を共同作成者として追加
3. キーボルトへ[1]をキーコンテナシークレットユーザとして追加
4. キーボルトへ、AppServiceをキーコンテナシークレットユーザとして追加
5. SQLServerへネットワークへIPアドレスを追加
6. SQLServerへネットワークへ例外、Azureサービスおよびリソースにこのサーバーへのアクセス許可するをチェックOn
7. AppService 環境変数(DOCKER_REGISTRY_SERVER_PASSWORD)へACRのパスワードを設定

## 3. Acr Depoly
```powershell
docker build -t eventattendeesapp .

docker login creventattendees.azurecr.io

docker tag eventattendeesapp creventattendees.azurecr.io/eventattendeesapp:latest
docker push creventattendees.azurecr.io/eventattendeesapp:latest
```

## 4. AzDOサービスコネクション作成
1. AzureDevOpsプロジェクトへサービスコネクションをAzure Resource Managerで作成
2. Azure DevOpsプロジェクトへサービスコネクションをDocker Registryで作成
