# n8n Workflows

Eight workflows make up the system. Import them in the order below.

| Order | File | Workflow | Trigger | What it does |
|---|---|---|---|---|
| 0 | `00-global-error-handler.json` | Hotel - Global Error Handler | Error Trigger | Logs any failure to `error_logs` and emails an alert |
| 1 | `01-check-availability-tool.json` | Hotel - Check Availability Tool | Execute Workflow + Webhook | Counts confirmed bookings that overlap the dates and returns rooms left and rate |
| 2 | `02-create-booking-tool.json` | Hotel - Create Booking Tool | Execute Workflow + Webhook | Re-checks availability, saves the booking, returns a `confirmation_id` |
| 3 | `03-modify-booking-tool.json` | Hotel - Modify Booking Tool | Execute Workflow + Webhook | Moves a booking to new dates if the room is free |
| 4 | `04-cancel-booking-tool.json` | Hotel - Cancel Booking Tool | Execute Workflow + Webhook | Cancels a booking and says whether the 48-hour fee applies |
| 5 | `05-escalate-to-staff-tool.json` | Hotel - Escalate to Staff Tool | Execute Workflow + Webhook | Logs the request and sends a styled HTML email to staff |
| 6 | `06-get-info-tool-voice.json` | Hotel - Get Info Tool (Voice) | Webhook | Returns the Google Doc knowledge base for the voice agent |
| 7 | `07-hotel-receptionist-agent.json` | Hotel Receptionist Agent | Website Webhook | The AI agent for website chat, with memory and all six tools |

## Why the tools have two triggers

The chat agent calls the tools through n8n's Execute Workflow Trigger. The voice agent lives in ElevenLabs, so it calls the same tools through a public Webhook. Both triggers feed one `Normalize Input` node, so the logic behind it is identical for either channel. The webhook path checks an `x-api-key` header, and the internal path does not need it.

## Import steps

1. Import workflow 0 first. Open each other workflow's settings and set **Error Workflow** to the Global Error Handler.
2. Import workflows 1 to 6. **Publish each one.** An unpublished tool workflow fails with "Workflow is not active" when the agent calls it.
3. Import workflow 7. Open each of the six tool nodes (`check_availability`, `create_booking`, and so on) and select the matching imported workflow.
4. Publish workflow 7.

## Placeholders to replace after import

| Placeholder | Where | Replace with |
|---|---|---|
| `YOUR_SHARED_SECRET` | Code nodes named `Normalize Input` and `Check Auth` | A long random string. Use the same value in the ElevenLabs tool headers |
| `alerts@example.com` | Gmail nodes in the escalation and error handler workflows | The inbox that should receive alerts |
| `YOUR_GOOGLE_DOC_ID` | Google Docs nodes | The ID of your knowledge base Google Doc |
| Credentials | Supabase, Google Docs, Gmail, OpenRouter nodes | Your own n8n credentials |
| `your-n8n-domain.com` | Any URL text | Your n8n domain |

## Two things worth knowing

- Error workflows only fire on **production** executions, not manual test runs in the editor.
- Each tool node in the agent has a field schema (name, type, required) defined for its inputs. Without it, the model can send arguments in the wrong shape and the tool receives empty values.
