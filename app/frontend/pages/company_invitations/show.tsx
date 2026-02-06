import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Form } from "@inertiajs/react"
import { Building2, Clock, Mail, Shield, User } from "lucide-react"
import { Spinner } from "@/components/ui/spinner"

interface Invitation {
  token: string
  company_name: string
  email: string
  role: string
  expires_at: string
}

interface Props {
  invitation: Invitation
}

export default function CompanyInvitationsShow({ invitation }: Props) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="container max-w-2xl mx-auto py-8 px-4">
      <Card>
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center">
            <Building2 className="h-6 w-6 text-primary" />
          </div>
          <CardTitle className="text-2xl">You've been invited!</CardTitle>
          <CardDescription className="text-base">
            You've been invited to join <strong>{invitation.company_name}</strong>
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-4">
            <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
              <div className="flex items-center gap-3">
                <Mail className="h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Invited email</p>
                  <p className="font-medium">{invitation.email}</p>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
              <div className="flex items-center gap-3">
                {invitation.role === 'administrator' ? (
                  <Shield className="h-5 w-5 text-muted-foreground" />
                ) : (
                  <User className="h-5 w-5 text-muted-foreground" />
                )}
                <div>
                  <p className="text-sm text-muted-foreground">Your role</p>
                  <Badge variant={invitation.role === 'administrator' ? 'default' : 'secondary'}>
                    {invitation.role}
                  </Badge>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
              <div className="flex items-center gap-3">
                <Clock className="h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Expires</p>
                  <p className="font-medium">{formatDate(invitation.expires_at)}</p>
                </div>
              </div>
            </div>
          </div>

          <Form 
            action="/company_redemptions" 
            method="post"
          >
            {({ processing }) => (
              <>
                <input type="hidden" name="token" value={invitation.token} />
              <div className="flex flex-col gap-3">
                <Button 
                  type="submit" 
                  disabled={processing}
                  className="w-full"
                  size="lg"
                >
                  {processing && <Spinner />}
                  Accept Invitation
                </Button>
                <p className="text-center text-sm text-muted-foreground">
                  By accepting, you'll become a {invitation.role} of {invitation.company_name}
                </p>
              </div>
              </>
            )}
          </Form>
        </CardContent>
      </Card>
    </div>
  )
}