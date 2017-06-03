# darwin_metrics.pl

stole from https://github.com/mackerelio/mackerel-agent/tree/master/metrics/darwin

```
usage: ./darwin_metrics.pl (memory|cpuusage)
```

### memory

```console
$ ./darwin_metrics.pl memory | jq .
{
  "swap_total": 1024,
  "swap_free": 920,
  "used": 6672,
  "cached": 1448,
  "swap_used": 103,
  "free": 65,
  "total": 8185
}
```

### cpuusage

```console
$ ./darwin_metrics.pl cpuusage | jq .
{
  "5m": 1.76,
  "id": 86,
  "15m": 1.72,
  "us": 10,
  "sy": 4,
  "1m": 2
}
```
