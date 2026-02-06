import { Link } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { 
  Plus, 
  Building, 
  MapPin, 
  Calendar, 
  DollarSign,
  AlertCircle,
  Clock
} from "lucide-react"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"
import { format } from "date-fns"

interface Project {
  id: number
  name: string
  project_type: string
  status: string
  address: string | null
  budget: string
  start_date: string | null
  estimated_completion_date: string | null
  days_until_completion: number | null
  overdue: boolean
  created_at: string
}

interface Props {
  projects: Project[]
}

export default function ProjectsIndex({ projects }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Projects' }
  ])

  const getStatusBadgeVariant = (status: string) => {
    switch (status) {
      case 'active':
        return 'default'
      case 'completed':
        return 'outline'
      case 'on_hold':
        return 'secondary'
      case 'planning':
        return 'secondary'
      default:
        return 'outline'
    }
  }

  const getProjectTypeIcon = (type: string) => {
    return type === 'new_build' ? '🏗️' : '🔨'
  }

  return (
    <div className="container max-w-7xl mx-auto py-8 px-4">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">Projects</h1>
          <p className="text-muted-foreground mt-2">
            Manage your construction and renovation projects
          </p>
        </div>
        <Link href="/projects/new">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Project
          </Button>
        </Link>
      </div>

      {projects.length === 0 ? (
        <Card>
          <CardContent className="text-center py-12">
            <Building className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">No projects yet</h3>
            <p className="text-muted-foreground mb-4">
              Create your first project to get started
            </p>
            <Link href="/projects/new">
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Create Project
              </Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {projects.map((project) => (
            <Link key={project.id} href={`/projects/${project.id}`}>
              <Card className="hover:shadow-lg transition-shadow cursor-pointer h-full">
                <CardHeader>
                  <div className="flex justify-between items-start mb-2">
                    <span className="text-2xl">{getProjectTypeIcon(project.project_type)}</span>
                    <Badge variant={getStatusBadgeVariant(project.status)}>
                      {project.status.replace('_', ' ')}
                    </Badge>
                  </div>
                  <CardTitle className="line-clamp-1">{project.name}</CardTitle>
                  <CardDescription className="space-y-2 mt-3">
                    {project.address && (
                      <div className="flex items-center gap-1">
                        <MapPin className="h-3 w-3" />
                        <span className="text-xs line-clamp-1">{project.address}</span>
                      </div>
                    )}
                    {project.budget && (
                      <div className="flex items-center gap-1">
                        <DollarSign className="h-3 w-3" />
                        <span className="text-xs">{project.budget}</span>
                      </div>
                    )}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {project.start_date && (
                      <div className="flex items-center gap-1 text-xs text-muted-foreground">
                        <Calendar className="h-3 w-3" />
                        Started {format(new Date(project.start_date), 'MMM d, yyyy')}
                      </div>
                    )}
                    {project.estimated_completion_date && (
                      <div className="flex items-center gap-1 text-xs text-muted-foreground">
                        <Clock className="h-3 w-3" />
                        {project.overdue ? (
                          <span className="text-destructive flex items-center gap-1">
                            <AlertCircle className="h-3 w-3" />
                            Overdue
                          </span>
                        ) : project.days_until_completion !== null ? (
                          <span>
                            {project.days_until_completion === 0
                              ? 'Due today'
                              : project.days_until_completion === 1
                              ? 'Due tomorrow'
                              : `${project.days_until_completion} days remaining`}
                          </span>
                        ) : (
                          <span>
                            Est. {format(new Date(project.estimated_completion_date), 'MMM d, yyyy')}
                          </span>
                        )}
                      </div>
                    )}
                  </div>
                  <div className="mt-3 pt-3 border-t">
                    <Badge variant="outline" className="text-xs">
                      {project.project_type.replace('_', ' ')}
                    </Badge>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}