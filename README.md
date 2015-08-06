
Threatmonitor - Packet Analysis suite with MonetDB / MySQL - RabbitMQ & PCap integration


 `,`,`,`
 ------
( ͡° ͜ʖ ͡°)
 \    /
  \--/


![GeoIP](https://raw.githubusercontent.com/puppetpies/threatmonitor/master/screenshot-3-geo.jpg)

Getting Started

Things you need

RabbitMQ

MonetDB or MySQL

Ruby 2.1.x ( 2.2 we have a issue building eventmachine native )

Libpcap 1.5.3 ( For pcaplet to build )

Pcaplet - https://github.com/ahobson/ruby-pcap

PCAPRUB - https://github.com/puppetpies/pcaprub - For Interface Realtime capture / dumping to disk ( Comming soon )

Docker Image ( https://hub.docker.com/u/puppetpies ( docker pull puppetpies/threatmonitor-suite ) )

Rubygem released 0.1.9 at time of writing ( gem install thm ) https://rubygems.org/gems/thm

![Dashboard](https://raw.githubusercontent.com/puppetpies/threatmonitor/master/screenshot-1.jpg)

To build:

You'll need PCAP / Development Header files

gem build pcap.gemspec
gem install pcap-0.7.7.gem 

GEMS: AMQP, Bunny, Eventmachine, guid, MonetDB, mysql, pcaplet

This is all experimental but i believe it works well so far.

Features ability to push pcap data to Message Queue.

Read data from disk into message queue

Write data from message queue to disk.

Allows you to easily move IP / TCP / UDP data with ease and analyze else where

Creating your database once you've installed MonetDB

monetdbd create /path/to/dbfarm

monetdbd start /path/to/dbfarm

monetdb create threatmonitor

monetdb release threatmonitor

monetdb start threatmonitor

Import the schema from the SQL provided now moved to sql/

I've now included MySQL Database support also however if your going to create big data sets i think i would use MonetDB

![Dashboard Other](https://raw.githubusercontent.com/puppetpies/threatmonitor/master/screenshot-4.jpg)

Have fun !
