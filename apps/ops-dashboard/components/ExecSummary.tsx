import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { AlertCircle, CheckCircle2, TrendingUp } from "lucide-react"
import overviewData from "@/data/overview.json"
import runsData from "@/data/runs.json"

export function ExecSummary() {
  const { kpis, recommendedActions } = overviewData
  const lastRun = runsData[0] // Most recent run
  const topActions = recommendedActions.slice(0, 3)

  return (
    <Card className="border-primary/20 bg-card/50">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg font-semibold tracking-tight">
            Executive Summary
          </CardTitle>
          <div className="flex items-center gap-2">
            {lastRun.status === "success" ? (
              <CheckCircle2 className="h-4 w-4 text-green-500" />
            ) : lastRun.status === "failed" ? (
              <AlertCircle className="h-4 w-4 text-red-500" />
            ) : null}
            <span className="text-xs text-muted-foreground">
              {new Date(lastRun.startedAt).toLocaleString()}
            </span>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-3">
        {/* KPI Grid */}
        <div className="grid grid-cols-4 gap-3">
          <div className="rounded-md border border-border/50 bg-background/50 p-2.5">
            <div className="flex items-center gap-1.5">
              <TrendingUp className="h-3.5 w-3.5 text-primary" />
              <span className="text-xs text-muted-foreground">Active</span>
            </div>
            <p className="mt-1 text-xl font-bold tabular-nums text-primary">
              {kpis.activeTasks}
            </p>
          </div>
          <div className="rounded-md border border-border/50 bg-background/50 p-2.5">
            <div className="flex items-center gap-1.5">
              <AlertCircle className="h-3.5 w-3.5 text-yellow-500" />
              <span className="text-xs text-muted-foreground">Blocked</span>
            </div>
            <p className="mt-1 text-xl font-bold tabular-nums text-yellow-500">
              {kpis.blocked}
            </p>
          </div>
          <div className="rounded-md border border-border/50 bg-background/50 p-2.5">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
              <span className="text-xs text-muted-foreground">Merges</span>
            </div>
            <p className="mt-1 text-xl font-bold tabular-nums text-green-500">
              {kpis.mergesToday}
            </p>
          </div>
          <div className="rounded-md border border-border/50 bg-background/50 p-2.5">
            <span className="text-xs text-muted-foreground">Last Run</span>
            <p className="mt-1 text-sm font-medium text-foreground">
              {kpis.lastRun}
            </p>
          </div>
        </div>

        {/* Last Run Result */}
        <div className="rounded-md border border-border/50 bg-background/50 p-2.5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Badge
                variant={
                  lastRun.status === "success"
                    ? "success"
                    : lastRun.status === "failed"
                    ? "destructive"
                    : "secondary"
                }
                className="text-xs"
              >
                {lastRun.status}
              </Badge>
              <span className="text-sm font-medium">{lastRun.summary}</span>
            </div>
            <span className="text-xs tabular-nums text-muted-foreground">
              {lastRun.duration}s
            </span>
          </div>
        </div>

        {/* Top 3 Actions */}
        <div className="space-y-1.5">
          <p className="text-xs font-medium text-muted-foreground">Priority Actions</p>
          {topActions.map((action) => (
            <div
              key={action.id}
              className="flex items-center justify-between rounded-md border border-border/50 bg-background/50 p-2"
            >
              <div className="flex items-center gap-2">
                <Badge
                  variant={action.priority === "high" ? "destructive" : "warning"}
                  className="h-5 text-[10px] px-1.5"
                >
                  {action.priority}
                </Badge>
                <span className="text-xs font-medium">{action.title}</span>
              </div>
              <span className="text-[10px] text-muted-foreground uppercase tracking-wider">
                {action.category}
              </span>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
