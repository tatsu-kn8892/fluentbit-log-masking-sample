# 概要
input_data.txtのjsonログをパースし、  
生ログとマスキング済みのログを別の出力先に連携をするfluentbitサンプル。

# 動作方法
参考: https://zenn.dev/amezousan/scraps/d41491d800d682

## terminal 1
fluent-bit起動

``` sh
docker pull fluent/fluent-bit:latest-debug

rm -f ./logs/* && \
docker run --name fluentbit --rm -v $(pwd):/work \
  fluent/fluent-bit:latest-debug \
  /fluent-bit/bin/fluent-bit -c /work/fluentbit-config.yaml
```

## terminal2
input_data.txtのデータをログとして送信

``` sh
docker exec -it fluentbit bash -c "echo '$(cat input_data.txt)' >> /tmp/test"
```
