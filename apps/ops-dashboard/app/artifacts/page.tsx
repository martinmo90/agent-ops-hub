import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Download, FileArchive, FileJson } from "lucide-react"
import artifactsData from "@/data/artifacts.json"

export default function ArtifactsPage() {
  const getIcon = (type: string) => {
    switch (type) {
      case "source":
      case "build":
        return FileArchive
      case "metadata":
        return FileJson
      default:
        return FileArchive
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Artifacts</h1>
        <p className="text-muted-foreground">Build outputs and generated files</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Latest Artifacts</CardTitle>
          <CardDescription>{artifactsData.length} files available</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {artifactsData.map((artifact) => {
              const Icon = getIcon(artifact.type)
              return (
                <div
                  key={artifact.name}
                  className="flex items-center justify-between rounded-lg border border-border p-4"
                >
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-md bg-primary/10">
                      <Icon className="h-5 w-5 text-primary" />
                    </div>
                    <div>
                      <p className="font-medium">{artifact.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {artifact.size} • {new Date(artifact.createdAt).toLocaleString()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge variant="outline">{artifact.type}</Badge>
                    <Button variant="outline" size="sm">
                      <Download className="mr-2 h-4 w-4" />
                      Download
                    </Button>
                  </div>
                </div>
              )
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
