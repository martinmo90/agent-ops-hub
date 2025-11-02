import type { Metadata } from "next"
import { Inter } from "next/font/google"
import { ThemeProvider } from "next-themes"
import Link from "next/link"
import {
  LayoutDashboard,
  CheckSquare,
  ThumbsUp,
  Package,
  Activity,
  Settings
} from "lucide-react"
import "./globals.css"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "Agent Ops Dashboard",
  description: "Unified dashboard for agent operations",
}

const navItems = [
  { href: "/", label: "Overview", icon: LayoutDashboard },
  { href: "/tasks", label: "Tasks", icon: CheckSquare },
  { href: "/approvals", label: "Approvals", icon: ThumbsUp },
  { href: "/artifacts", label: "Artifacts", icon: Package },
  { href: "/runs", label: "Runs & Logs", icon: Activity },
  { href: "/settings", label: "Settings", icon: Settings },
]

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider attribute="class" defaultTheme="dark" enableSystem={false}>
          <div className="flex h-screen bg-background">
            {/* Sidebar */}
            <aside className="w-64 border-r border-border bg-card">
              <div className="flex h-16 items-center border-b border-border px-6">
                <h1 className="text-lg font-semibold text-primary">Agent Ops</h1>
              </div>
              <nav className="space-y-1 p-4">
                {navItems.map((item) => {
                  const Icon = item.icon
                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      className="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
                    >
                      <Icon className="h-5 w-5" />
                      {item.label}
                    </Link>
                  )
                })}
              </nav>
            </aside>

            {/* Main content */}
            <div className="flex flex-1 flex-col">
              {/* Top header */}
              <header className="flex h-16 items-center border-b border-border px-6">
                <div className="flex-1">
                  <h2 className="text-xl font-semibold">Dashboard</h2>
                </div>
              </header>

              {/* Content area */}
              <main className="flex-1 overflow-auto p-6">
                {children}
              </main>
            </div>
          </div>
        </ThemeProvider>
      </body>
    </html>
  )
}
