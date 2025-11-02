import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import runsData from "@/data/runs.json"

export default function RunsPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Runs & Logs</h1>
          <p className="text-muted-foreground">CI/CD pipeline history and execution logs</p>
        </div>
        <Button>New Run</Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Recent Runs</CardTitle>
          <CardDescription>{runsData.length} total runs</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {runsData.map((run) => (
              <Card key={run.id}>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
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
                      >
                        {run.status}
                      </Badge>
                      <div>
                        <CardTitle className="text-lg">{run.summary}</CardTitle>
                        <CardDescription>
                          {new Date(run.startedAt).toLocaleString()} • {run.duration}s
                        </CardDescription>
                      </div>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <Tabs defaultValue="logs">
                    <TabsList>
                      <TabsTrigger value="logs">Logs</TabsTrigger>
                      <TabsTrigger value="details">Details</TabsTrigger>
                    </TabsList>
                    <TabsContent value="logs" className="mt-4">
                      <pre className="rounded-md bg-muted p-4 text-xs overflow-x-auto">
                        {run.logs}
                      </pre>
                    </TabsContent>
                    <TabsContent value="details" className="mt-4">
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Run ID:</span>
                          <span className="font-mono">{run.id}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Duration:</span>
                          <span>{run.duration}s</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Started:</span>
                          <span>{new Date(run.startedAt).toLocaleString()}</span>
                        </div>
                      </div>
                    </TabsContent>
                  </Tabs>
                </CardContent>
              </Card>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
