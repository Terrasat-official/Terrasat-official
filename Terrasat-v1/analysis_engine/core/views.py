from django.shortcuts import render
from django.shortcuts import render, redirect
from django.core.mail import send_mail
from django.contrib import messages
from django.conf import settings
from django.http import JsonResponse
from django.contrib.auth import authenticate, login
import json
from django.utils.decorators import method_decorator
from django.contrib.gis.geos import GEOSGeometry
import logging

from .models import *
from django.core.mail import send_mail, BadHeaderError
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.gis.geos import Polygon
from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator  # Add this import
from django.contrib.auth import get_user_model
from django.contrib.auth import logout

class SaveFieldView(APIView):
    def post(self, request, *args, **kwargs):
        try:
            data = request.data
            name = data.get('name', 'Unnamed Field')
            coordinates = data.get('coordinates')
            area = data.get('area', 0.0)  # Get area from frontend
            owner = request.user

            if not coordinates or len(coordinates) < 3:
                return Response({"error": "At least 3 points are required"})
            
            # Close the polygon by repeating first coordinate
            if coordinates[0] != coordinates[-1]:
                coordinates.append(coordinates[0])

            # Create polygon 
            polygon = Polygon(coordinates)

            # Save to database with the calculated area
            field = Field.objects.create(
                owner=owner, 
                name=name, 
                geometry=polygon,
                area=area  # Save the area from frontend
            )

            serializer = FieldGeoJSONSerializer(field)

            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
           


from rest_framework.decorators import api_view
from .models import Field
from .serializers import FieldGeoJSONSerializer

@api_view(['GET'])
def get_fields_geojson(request):
    fields = Field.objects.filter(owner=request.user)  # Query all fields
    serializer = FieldGeoJSONSerializer(fields, many=True)  # Serialize data
    return Response(serializer.data) 
    
@method_decorator(csrf_exempt, name='dispatch')
class DeleteFieldView(APIView):
    def delete(self, request, id):
        field = get_object_or_404(Field, id=id)
        field.delete()
        return Response({'message': 'Field deleted successfully'}, status=status.HTTP_200_OK)

