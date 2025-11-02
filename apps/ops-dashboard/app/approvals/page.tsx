import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"

const mockApprovals = [
  {
    id: "apr-1",
    title: "Deploy to production - v2.3.0",
    requester: "Agent Claude",
    requestedAt: "2025-11-02T09:00:00Z",
    status: "pending",
    impact: "high",
  },
  {
    id: "apr-2",
    title: "Merge PR #42 - Database schema changes",
    requester: "Agent Claude",
    requestedAt: "2025-11-02T07:30:00Z",
    status: "pending",
    impact: "medium",
  },
]

export default function ApprovalsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Approvals</h1>
        <p className="text-muted-foreground">Review and approve agent requests</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Pending Approvals</CardTitle>
          <CardDescription>{mockApprovals.length} items awaiting your review</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {mockApprovals.map((approval) => (
              <div
                key={approval.id}
                className="flex items-center justify-between rounded-lg border border-border p-4"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <p className="font-medium">{approval.title}</p>
                    <Badge variant={approval.impact === "high" ? "destructive" : "warning"}>
                      {approval.impact} impact
                    </Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    Requested by {approval.requester} •{" "}
                    {new Date(approval.requestedAt).toLocaleString()}
                  </p>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm">
                    Reject
                  </Button>
                  <Button size="sm">Approve</Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
