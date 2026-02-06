import { Link } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { 
  ArrowLeft,
  Edit,
  MapPin,
  Calendar,
  DollarSign,
  AlertCircle,
  Clock,
  CheckCircle,
  PauseCircle,
  PlayCircle
} from "lucide-react"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"
import { format } from "date-fns"

interface Project {
  id: number
  name: string
  description: string | null
  project_type: string
  status: string
  address: string | null
  city: string | null
  state: string | null
  zip_code: string | null
  full_address: string | null
  budget: number | null
  formatted_budget: string
  start_date: string | null
  estimated_completion_date: string | null
  days_until_completion: number | null
  overdue: boolean
  created_at: string
  updated_at: string
  company: {
    id: number
    name: string
  }
}

interface Props {
  project: Project
}

export default function ProjectsShow({ project }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Projects', href: '/projects' },
    { label: project.name }
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

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'active':
        return <PlayCircle className="h-4 w-4" />
      case 'completed':
        return <CheckCircle className="h-4 w-4" />
      case 'on_hold':
        return <PauseCircle className="h-4 w-4" />
      case 'planning':
        return <Clock className="h-4 w-4" />
      default:
        return null
    }
  }

  const getProjectTypeIcon = (type: string) => {
    return type === 'new_build' ? '🏗️' : '🔨'
  }

  return (
    <div className="container max-w-6xl mx-auto py-8 px-4">
      <div className="flex justify-between items-center mb-8">
        <div>
          <Link href="/projects" className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground mb-2">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Projects
          </Link>
          <div className="flex items-center gap-3">
            <span className="text-3xl">{getProjectTypeIcon(project.project_type)}</span>
            <div>
              <h1 className="text-3xl font-bold">{project.name}</h1>
              <p className="text-muted-foreground mt-1">
                {project.company.name}
              </p>
            </div>
          </div>
        </div>
        <Link href={`/projects/${project.id}/edit`}>
          <Button variant="outline">
            <Edit className="mr-2 h-4 w-4" />
            Edit
          </Button>
        </Link>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Project Details</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">Status</span>
              <Badge variant={getStatusBadgeVariant(project.status)} className="flex items-center gap-1">
                {getStatusIcon(project.status)}
                {project.status.replace('_', ' ')}
              </Badge>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">Type</span>
              <Badge variant="outline">
                {project.project_type.replace('_', ' ')}
              </Badge>
            </div>

            {project.description && (
              <div className="pt-2 border-t">
                <span className="text-sm font-medium block mb-2">Description</span>
                <p className="text-sm text-muted-foreground">{project.description}</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Location</CardTitle>
          </CardHeader>
          <CardContent>
            {project.full_address ? (
              <div className="space-y-3">
                <div className="flex items-start gap-2">
                  <MapPin className="h-4 w-4 mt-0.5 text-muted-foreground" />
                  <div className="text-sm">
                    {project.address && <div>{project.address}</div>}
                    {(project.city || project.state || project.zip_code) && (
                      <div>
                        {[project.city, project.state, project.zip_code]
                          .filter(Boolean)
                          .join(', ')}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">No location specified</p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Timeline</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {project.start_date && (
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm font-medium">Start Date</span>
                </div>
                <span className="text-sm">
                  {format(new Date(project.start_date), 'MMM d, yyyy')}
                </span>
              </div>
            )}
            
            {project.estimated_completion_date && (
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Clock className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm font-medium">Est. Completion</span>
                </div>
                <div className="text-right">
                  <div className="text-sm">
                    {format(new Date(project.estimated_completion_date), 'MMM d, yyyy')}
                  </div>
                  {project.overdue && project.status !== 'completed' && (
                    <Badge variant="destructive" className="mt-1 text-xs">
                      <AlertCircle className="mr-1 h-3 w-3" />
                      Overdue
                    </Badge>
                  )}
                  {!project.overdue && project.days_until_completion !== null && project.status !== 'completed' && (
                    <span className="text-xs text-muted-foreground">
                      {project.days_until_completion === 0
                        ? 'Due today'
                        : project.days_until_completion === 1
                        ? 'Due tomorrow'
                        : `${project.days_until_completion} days remaining`}
                    </span>
                  )}
                </div>
              </div>
            )}

            {!project.start_date && !project.estimated_completion_date && (
              <p className="text-sm text-muted-foreground">No timeline set</p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Budget</CardTitle>
          </CardHeader>
          <CardContent>
            {project.budget ? (
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm font-medium">Total Budget</span>
                </div>
                <span className="text-lg font-semibold">{project.formatted_budget}</span>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">No budget set</p>
            )}
          </CardContent>
        </Card>
      </div>

      <Card className="mt-6">
        <CardHeader>
          <CardTitle>Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2 text-sm">
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Created</span>
              <span>{format(new Date(project.created_at), 'MMM d, yyyy h:mm a')}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Last Updated</span>
              <span>{format(new Date(project.updated_at), 'MMM d, yyyy h:mm a')}</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}