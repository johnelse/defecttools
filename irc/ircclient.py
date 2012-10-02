#!/usr/bin/env python

import select
import socket
import string

class IRCMessage():
    def __init__(self, msg):
        # Basic parsing of a raw IRC message.
        values = map(lambda value: value.lstrip(':'), msg.split(' ', 3))
        missing = 4 - len(values)
        values = values + [None] * missing
        self.sender = values[0]
        self.command = values[1]
        self.target = values[2]
        self.message = values[3]

class IRCClient():
    def __init__(self, server, port, nick, password=None,
            username=None, ircname=None, handlers={}):
        self.server = server
        self.port = port
        self.nick = nick
        self.password = password
        self.username = username or nick
        self.ircname = ircname or nick
        self.handlers = handlers

    def send_raw(self, data):
        self.sock.send("%s\r\n" % data)

    def send_join(self, channel):
        self.send_raw("JOIN %s" % channel)

    def send_nick(self):
        self.send_raw("NICK %s" % self.nick)

    def send_pass(self):
        self.send_raw("PASS %s" % self.password)

    def send_pong(self, msg):
        self.send_raw("PONG %s" % msg)

    def send_privmsg(self, target, msg):
        self.send_raw("PRIVMSG %s :%s" % (target, msg))

    def send_user(self):
        self.send_raw("USER %s %s bla :%s" % (self.username, self.server, self.ircname))

    # Connect and register with the server.
    def connect(self):
        self.sock = socket.socket()
        self.sock.connect((self.server, self.port))
        if self.password:
            self.send_pass()
        self.send_nick()
        self.send_user()

    # Override this to enable the client to respond to chat messages.
    def on_recv(self, msg):
        pass

    def start(self):
        read_buffer = ""
        input_fds = self.handlers.keys()
        input_fds.append(self.sock)
        while True:
            (readable_fds, _, _) = select.select(input_fds, [], [])
            for fd in readable_fds:
                if fd == self.sock:
                    # Read from the IRC socket.
                    read_buffer = read_buffer + self.sock.recv(1024)
                    lines = string.split(read_buffer, "\n")
                    read_buffer = lines.pop()

                    for line in lines:
                        # Remove trailing \r
                        line = string.rstrip(line)
                        if line[0:4] == "PING":
                            # Handle PING from server.
                            self.send_pong(line[5:])
                        else:
                            msg = IRCMessage(line)
                            self.on_recv(msg)
                else:
                    # Read from one of the command file descriptors.
                    handler = self.handlers[fd]
                    handler(fd, self)
