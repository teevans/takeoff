import { Link, router } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { 
  UserPlus,
  Mail,
  Calendar,
  Clock,
  User,
  Trash2
} from "lucide-react"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"

interface Invitation {
  id: number
  email: string
  role: string
  invited_by: string
  expires_at: string
  created_at: string
}

interface Company {
  id: number
  name: string
}

interface Props {
  company: Company
  invitations: Invitation[]
}

export default function CompanyInvitationsIndex({ company, invitations }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Companies', href: '/companies' },
    { label: company.name, href: `/companies/${company.id}` },
    { label: 'Invitations' }
  ])
  
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  const handleDelete = (invitationId: number) => {
    router.delete(`/companies/${company.id}/company_invitations/${invitationId}`)
  }

  return (
    <div className="container max-w-6xl mx-auto py-8 px-4">
      <div className="flex justify-between items-center mb-8">
        <div className="flex items-center gap-4">
          <div>
            <h1 className="text-3xl font-bold">Pending Invitations</h1>
            <p className="text-muted-foreground mt-1">
              Manage invitations for {company.name}
            </p>
          </div>
        </div>
        <Link href={`/companies/${company.id}/company_invitations/new`}>
          <Button>
            <UserPlus className="mr-2 h-4 w-4" />
            New Invitation
          </Button>
        </Link>
      </div>

      {invitations.length === 0 ? (
        <Card>
          <CardContent className="text-center py-12">
            <Mail className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">No pending invitations</h3>
            <p className="text-muted-foreground mb-4">
              Invite team members to collaborate in your company
            </p>
            <Link href={`/companies/${company.id}/company_invitations/new`}>
              <Button>
                <UserPlus className="mr-2 h-4 w-4" />
                Send Invitation
              </Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardHeader>
            <CardTitle>Pending Invitations</CardTitle>
            <CardDescription>
              {invitations.length} pending {invitations.length === 1 ? 'invitation' : 'invitations'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Email</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Invited By</TableHead>
                  <TableHead>Sent</TableHead>
                  <TableHead>Expires</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {invitations.map((invitation) => (
                  <TableRow key={invitation.id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Mail className="h-4 w-4 text-muted-foreground" />
                        {invitation.email}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant={invitation.role === 'administrator' ? 'default' : 'secondary'}>
                        {invitation.role}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <User className="h-4 w-4 text-muted-foreground" />
                        {invitation.invited_by}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Calendar className="h-4 w-4 text-muted-foreground" />
                        {formatDate(invitation.created_at)}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Clock className="h-4 w-4 text-muted-foreground" />
                        {formatDate(invitation.expires_at)}
                      </div>
                    </TableCell>
                    <TableCell className="text-right">
                      <AlertDialog>
                        <AlertDialogTrigger asChild>
                          <Button variant="ghost" size="sm">
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>Cancel invitation?</AlertDialogTitle>
                            <AlertDialogDescription>
                              This will cancel the invitation to {invitation.email}. 
                              They will no longer be able to join using this invitation link.
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>Keep invitation</AlertDialogCancel>
                            <AlertDialogAction onClick={() => handleDelete(invitation.id)}>
                              Cancel invitation
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  )
}