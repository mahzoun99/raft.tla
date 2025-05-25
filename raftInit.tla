------------------------------ MODULE raftInit ------------------------------

EXTENDS raftHelpers

\* [P1] Initialize Variables!
InitHistoryVars == voterLog  = [i \in Server |-> [j \in {} |-> <<>>]]
InitServerVars == /\ currentTerm = [i \in Server |-> 1]
                  /\ state       = [i \in Server |-> Follower]
                  /\ votedFor    = [i \in Server |-> Nil]
InitCandidateVars == /\ votesResponded = [i \in Server |-> {}]
                     /\ votesGranted   = [i \in Server |-> {}]
\* The values nextIndex[i][i] and matchIndex[i][i] are never read, since the
\* leader does not send itself messages. It's still easier to include these
\* in the functions.
InitLeaderVars == /\ nextIndex  = [i \in Server |-> [j \in Server |-> 1]]
                  /\ matchIndex = [i \in Server |-> [j \in Server |-> 0]]
InitLogVars == /\ log          = [i \in Server |-> << >>]
               /\ commitIndex  = [i \in Server |-> 0]
Init == /\ messages = [m \in {} |-> 0]
        /\ InitHistoryVars
        /\ InitServerVars
        /\ InitCandidateVars
        /\ InitLeaderVars
        /\ InitLogVars
        /\ maxc = 0
        /\ leaderCount = [i \in Server |-> 0]
        /\ entryCommitStats = [ idx_term \in {} |-> [ sentCount |-> 0, ackCount |-> 0, committed |-> FALSE ] ] \* Initialize new variable

\* MyInit remains unchanged for the core Raft state, entryCommitStats is handled in Init.
\* [P1] Initialize Switch as a server!
MyInit ==
    LET ServerIds == CHOOSE ids \in [0..3 -> Server] : TRUE
        r1 == ServerIds[1]
        r2 == ServerIds[2] \* Leader
        r3 == ServerIds[3]
        r0 == ServerIds[0] \* Switch
        HCRServer == Server \ {r0}
    IN
    /\ commitIndex = [s \in Server |-> 0]
    /\ currentTerm = [s \in Server |-> 2]
    /\ leaderCount = [s \in Server |-> IF s = r2 THEN 1 ELSE 0]
    /\ log = [s \in Server |-> <<>>]
    /\ matchIndex = [s \in Server |-> [t \in Server |-> 0]]
    /\ maxc = 0
    /\ messages = [m \in {} |-> 0]  \* Start with empty messages
    /\ nextIndex = [s \in Server |-> [t \in Server |-> 1]]
    /\ state = [s \in Server |-> IF s = r0 THEN Switch ELSE IF s = r2 THEN Leader ELSE Follower]
    /\ votedFor = [s \in Server |-> IF (s = r2 \/ s = r0) THEN Nil ELSE r2]
    /\ voterLog = [s \in Server |-> IF s = r0 THEN Nil ELSE IF s = r2 THEN (r1 :> <<>> @@ r3 :> <<>>) ELSE <<>>]
    /\ votesGranted = [s \in Server |-> IF s = r0 THEN Nil ELSE IF s = r2 THEN {r1, r3} ELSE {}]
    /\ votesResponded = [s \in Server |-> IF s = r0 THEN Nil ELSE IF s = r2 THEN {r1, r3} ELSE {}]
    /\ entryCommitStats = [ idx_term \in {} |-> [ sentCount |-> 0, ackCount |-> 0, committed |-> FALSE ] ] \* Initialize here too
    /\ switchBuffer = [v \in {} |-> 0]
    /\ unorderedRequests = [s \in HCRServer |-> {}]
    /\ switchSentRecord = [s \in HCRServer |-> {}]
    /\ switchIndex = "r0"

\* to be used directly in model Init the value
\*MyInit2 ==
\*    /\  commitIndex = (r1 :> 0 @@ r2 :> 0 @@ r3 :> 0)
\*    /\  currentTerm = (r1 :> 2 @@ r2 :> 2 @@ r3 :> 2)
\*    /\  entryCommitStats = << >>
\*    /\  leaderCount = (r1 :> 1 @@ r2 :> 0 @@ r3 :> 0)
\*    /\  log = (r1 :> <<>> @@ r2 :> <<>> @@ r3 :> <<>>)
\*    /\  matchIndex = ( r1 :> (r1 :> 0 @@ r2 :> 0 @@ r3 :> 0) @@
\*      r2 :> (r1 :> 0 @@ r2 :> 0 @@ r3 :> 0) @@
\*      r3 :> (r1 :> 0 @@ r2 :> 0 @@ r3 :> 0) )
\*    /\  maxc = 0
\*    /\  messages = << >>
\*    /\  nextIndex = ( r1 :> (r1 :> 1 @@ r2 :> 1 @@ r3 :> 1) @@
\*      r2 :> (r1 :> 1 @@ r2 :> 1 @@ r3 :> 1) @@
\*      r3 :> (r1 :> 1 @@ r2 :> 1 @@ r3 :> 1) )
\*    /\  state = (r1 :> Leader @@ r2 :> Follower @@ r3 :> Follower)
\*    /\  votedFor = (r1 :> Nil @@ r2 :> r1 @@ r3 :> r1)
\*    /\  voterLog = (r1 :> (r1 :> <<>>) @@ r2 :> <<>> @@ r3 :> <<>>)
\*    /\  votesGranted = (r1 :> {r1} @@ r2 :> {} @@ r3 :> {})
\*    /\  votesResponded = (r1 :> {r1} @@ r2 :> {} @@ r3 :> {})


=============================================================================
\* Created by Ovidiu-Cristian Marcu
