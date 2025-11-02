import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import overviewData from "@/data/overview.json"
import runsData from "@/data/runs.json"

export default function OverviewPage() {
  const { kpis, recommendedActions } = overviewData
  const recentRuns = runsData.slice(0, 3)

  return (
    <div className="space-y-6">
      {/* KPIs */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Active Tasks</CardDescription>
            <CardTitle className="text-3xl">{kpis.activeTasks}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Blocked</CardDescription>
            <CardTitle className="text-3xl text-yellow-500">{kpis.blocked}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Merges Today</CardDescription>
            <CardTitle className="text-3xl text-green-500">{kpis.mergesToday}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Last Run</CardDescription>
            <CardTitle className="text-lg">{kpis.lastRun}</CardTitle>
          </CardHeader>
        </Card>
      </div>

      {/* Recommended Actions */}
      <Card>
        <CardHeader>
          <CardTitle>Recommended Actions</CardTitle>
          <CardDescription>High-priority items requiring attention</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {recommendedActions.map((action) => (
              <div
                key={action.id}
                className="flex items-center justify-between rounded-lg border border-border p-4"
              >
                <div className="flex items-center gap-3">
                  <Badge variant={action.priority === "high" ? "destructive" : "warning"}>
                    {action.priority}
                  </Badge>
                  <div>
                    <p className="font-medium">{action.title}</p>
                    <p className="text-sm text-muted-foreground">{action.category}</p>
                  </div>
                </div>
                <Button variant="outline" size="sm">
                  View
                </Button>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
          <CardDescription>Latest runs and operations</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {recentRuns.map((run) => (
              <div
                key={run.id}
                className="flex items-center justify-between rounded-lg border border-border p-4"
              >
                <div className="flex items-center gap-3">
                  <Badge
                    variant={
                      run.status === "success"
                        ? "success"
                        : run.status === "failed"
                        ? "destructive"
                        : "secondary"
                    }
                  >
                    {run.status}
                  </Badge>
                  <div>
                    <p className="font-medium">{run.summary}</p>
                    <p className="text-sm text-muted-foreground">
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
