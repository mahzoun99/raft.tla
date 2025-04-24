Understanding: Add a Switch between the client and the leader + servers.
To do so:
1. We need a new CONSTANT as a switch
2. We need to send requests from the client to Switch instead of the Leader!
3. Switch will broadcast the message to all servers! (leader and followers)
4. The Leader will do the same as before, but without a payload! Just referencing the client request.
5. Followers should get the payload from their Cache!
6. What if the Cache does not have the message?

Modifications: (raftConstants --> raftVariables --> raftInit --> raftActionsSolution)\
New CONSTANTS: Switch\
New VARIABLES: Adding UnorderedCache to the serverVars\
Initialized the UnorderedCache in InitServerVars!\
Add UnorderedCache to UNCHANGED of all actions before AppendEntries!\
TODO: Modify AppendEntries to include the Switch.

What do I need next?
- Change the Client request to be received by Swith!
- New action for broadcasting a request from the switch to every server!
- Receiving request from Switch to Leader.
- Receiving request from Switch to Followers.
- Change the Leader broadcast to followers! (Remove the payload)
- Change the Rcv leaders req (get the payload from the cache)
