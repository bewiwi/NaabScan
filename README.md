### Welcome to Naabscan page.
Naabscan is a perl daemon which works with xml file generated by Nmap.
He can execute trigger when a scan correspond to a SQL request.

### How it works ?
![NaabScan.png](https://dl.dropboxusercontent.com/u/23756470/naabscan.png)

### Installation
Download or clone NaabScan, unzip if necessary and config
```
cp config-dist.pl config.pl
vim config.pl
```
You must edit config.pl to set database parameter, number of worker, nmap config, xml folder and trigger

### Usage
Once the config file is set just exec start.pl

```
chmod +x start.pl
./start.pl
```

### Contribution
All contribution are welcome.
