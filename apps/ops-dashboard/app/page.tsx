import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { ExecSummary } from "@/components/ExecSummary"
import overviewData from "@/data/overview.json"
import runsData from "@/data/runs.json"

export default function OverviewPage() {
  const { recommendedActions } = overviewData
  const recentActivity = runsData.slice(0, 5)

  return (
    <div className="space-y-4">
      {/* Executive Summary Panel */}
      <ExecSummary />

      {/* Recommended Actions */}
      <Card className="border-border/50">
        <CardHeader className="pb-3">
          <CardTitle className="text-base">Recommended Actions</CardTitle>
          <CardDescription className="text-xs">
            High-priority items requiring attention
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {recommendedActions.map((action) => (
              <div
                key={action.id}
                className="flex items-center justify-between rounded-md border border-border/50 bg-background/50 p-2.5"
              >
                <div className="flex items-center gap-2.5">
                  <Badge
                    variant={action.priority === "high" ? "destructive" : "warning"}
                    className="h-5 text-[10px] px-1.5"
                  >
                    {action.priority}
                  </Badge>
                  <div>
                    <p className="text-sm font-medium">{action.title}</p>
                    <p className="text-xs text-muted-foreground">{action.description}</p>
                  </div>
                </div>
                <span className="text-[10px] uppercase tracking-wider text-muted-foreground">
                  {action.category}
                </span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Recent Activity - 5 most recent runs */}
      <Card className="border-border/50">
        <CardHeader className="pb-3">
          <CardTitle className="text-base">Activity Log</CardTitle>
          <CardDescription className="text-xs">
            Latest 5 runs and operations
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {recentActivity.map((run) => (
              <div
                key={run.id}
                className="flex items-center justify-between rounded-md border border-border/50 bg-background/50 p-2.5"
              >
                <div className="flex items-center gap-2.5 flex-1 min-w-0">
                  <Badge
                    variant={
                      run.status === "success"
                        ? "success"
                        : run.status === "failed"
                        ? "destructive"
                        : run.status === "cancelled"
                        ? "secondary"
                        : "warning"
                    }
                    className="h-5 text-[10px] px-1.5 shrink-0"
                  >
                    {run.status}
                  </Badge>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{run.summary}</p>
                    <p className="text-xs text-muted-foreground tabular-nums">
                      {new Date(run.startedAt).toLocaleString()} • {run.duration}s
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
