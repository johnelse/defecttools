from defecttools.irc import ircclient
from multiprocessing import Pipe, Process

import re

# Simple bot implementation which echos messages addressed to it via PRIVMSG.
class DefectBot(ircclient.IRCClient):
    def on_recv(self, msg):
        if msg.message:
            prefix = re.compile("%s: (.*)" % self.nick)
            matches = prefix.match(msg.message)
            if matches:
                data = matches.group(1)
                self.send_privmsg(msg.sender, data)

# Join the bot to a channel and start its event loop.
def run(server, port, nick, password, channel, handlers):
    bot = DefectBot(server, port, nick, password, handlers=handlers)
    bot.connect()
    bot.send_join(channel)
    bot.start()

# Create a pipe and spawn a bot process.
# One end of the pipe will be passed to the bot; the other end will be returned.
def spawn(server, port, nick, password, channel, handler_fn):
    parent_fd, child_fd = Pipe()
    handlers = {child_fd: handler_fn}
    child = Process(target=run, args=(server, port, nick, password, channel, handlers))
    child.start()
    return parent_fd
