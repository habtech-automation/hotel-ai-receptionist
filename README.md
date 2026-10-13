# Hotel AI Receptionist (Voice + Chat)

An AI receptionist for hotels that answers website chats and phone calls, checks real room availability, handles bookings, and hands the guest to staff when a human is needed. It is built on n8n, Supabase, and ElevenLabs.

> Portfolio build. It is modeled on a public Upwork job brief for a hotel AI receptionist and runs on a fictional demo hotel (Grandview Hotel) with a Supabase table standing in for a real booking system.

**Demo video:** [Watch the demo](https://habtech.neetorecord.com/watch/6551a5a6063bd1ea90d3)

## The problem

Hotels lose guests in quiet ways.

- A guest messages or calls after the front desk is busy or closed, and nobody replies.
- Staff spend the day answering the same questions: room rates, check-in time, airport transfers, changing a reservation.
- Chat, phone, and bookings often live in separate places, so answers and availability do not match.

## What it does

- Answers website chat and phone calls at any hour, from the same knowledge and the same booking data
- Checks real room availability before it quotes a price
- Creates, changes, and cancels reservations
- Says a booking is confirmed **only** when the booking system returns a confirmation ID
- Answers questions about rooms, amenities, policies, dining, and nearby places from one Google Doc that staff can edit
- Hands the guest to a real staff member by email, with the right department and urgency, when it cannot or should not handle the request
- Logs every failure and alerts the owner, so problems are found before guests report them

## Business impact

| For the hotel | How the system delivers it |
|---|---|
| No missed enquiries | Chat and voice answer around the clock |
| Less repeated work for staff | Routine questions are answered from the knowledge doc |
| No false confirmations | The agent cannot confirm a booking without a real confirmation ID |
| Easy to keep current | Staff edit one Google Doc, and no code change is needed |
| Humans stay in control | Complaints, payments, and special requests go to staff with the details collected |
| Problems found early | Failures are logged and emailed instantly |

## How it works

**Website chat**

Guest → Website chat → n8n webhook → AI agent (GPT-4o, conversation memory) → tools → Supabase / Google Docs / Gmail → reply to guest

**Phone and voice widget**

Guest → ElevenLabs voice agent (GPT-4o, Nigerian English voice) → webhook tools → n8n → Supabase / Google Docs / Gmail → spoken reply

**When something fails**

Any workflow error → Global Error Handler → row in `error_logs` + styled email alert

**The six tools (shared by chat and voice)**

`get_hotel_info` · `check_availability` · `create_booking` · `modify_booking` · `cancel_booking` · `escalate_to_staff`

## Built to be reliable

- **No booking without proof.** `create_booking` re-checks availability, saves the row, and only then returns a `confirmation_id`. The agent's rules forbid saying "confirmed" without one.
- **Availability before price.** The agent must call `check_availability` before quoting a rate.
- **Safe webhooks.** Public endpoints require an `x-api-key` header.
- **Retries.** Database, email, and document calls retry once after a short wait before failing.
- **Global error handler.** One workflow catches failures from all the others, saves them, and emails an alert.
- **Human handoff.** `escalate_to_staff` saves the request and emails staff a formatted summary. Emergencies are never routed through it, and the agent tells the guest to call emergency services.

## Tested the hard way

- Every tool was tested directly through its webhook and through the chat agent in natural conversation.
- The voice agent was tested with ElevenLabs simulated calls. One test caught the agent not asking for a caller's name, and the prompt was fixed.
- A failure was forced on purpose to confirm the error handler logs it and sends the alert.
- Bugs found and fixed along the way:
  - A tool silently returned nothing when a room type had zero existing bookings.
  - The model sent malformed arguments until each tool's input schema was defined.
  - Tool workflows had to be published before the agent could call them.
  - Voice agent edits had to be deployed before callers could reach them.

## Tech stack

| Layer | Tool |
|---|---|
| Automation and agent logic | n8n (self-hosted) |
| Chat model | GPT-4o through OpenRouter |
| Voice | ElevenLabs Conversational AI (GPT-4o, Nigerian English voice) |
| Database | Supabase (Postgres) |
| Knowledge base | Google Docs |
| Staff alerts | Gmail |

## Setup

1. **Database.** Create a Supabase project and run `database/schema.sql` in the SQL editor.
2. **Credentials in n8n.** Add Supabase (use the service role key, server side only), Google Docs, Gmail, and OpenRouter.
3. **Knowledge base.** Copy `knowledge-base/sample-hotel-knowledge-base.md` into a Google Doc and note its ID.
4. **Workflows.** Import the files in `workflows/` in order, replace the placeholders, and publish. See `workflows/README.md`.
5. **Voice agent.** Create the six webhook tools and the agent using `elevenlabs/agent-config.md`, then deploy it to 100% of traffic.
6. **Website.** Send chat messages to your agent webhook, and add the ElevenLabs widget snippet for voice.

Chat request shape:

```
POST https://YOUR-N8N-DOMAIN/webhook/hotel-chat-agent
Header: x-api-key: YOUR_SHARED_SECRET
Body:   { "chatInput": "Do you have a Deluxe room on Dec 10?", "sessionId": "unique-id-per-visitor" }
```

## Known limits (and what production would add)

- The booking system is a Supabase mock. A real hotel would connect its property management system through the same tool interface.
- The availability check and booking save are not one database transaction. Two guests booking the last room at the exact same moment could both succeed. A production version would lock or use a database function.
- Cancellation reports whether a fee applies. It does not charge anyone, and no payments are handled.

## Files

| Path | What it is |
|---|---|
| `workflows/` | The eight n8n workflow exports and an import guide |
| `database/schema.sql` | Tables for rooms, bookings, escalations, and error logs, with demo rooms |
| `knowledge-base/` | Sample hotel knowledge base for the Google Doc |
| `elevenlabs/agent-config.md` | Voice agent settings, system prompt, and webhook tool definitions |
